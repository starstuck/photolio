require 'ftools'
require 'digest/md5'


class ActionController::Base
  public :render_component_as_string
end


module Publisher

  class LocalFileWriter
    attr_reader :base_path

    def initialize(base_path)
      validate_folder(base_path)
      @base_path = base_path
    end

    def validate_folder(path)
      if not (path and (path != '') and File.directory?(path))
        raise ArgumentError.new("Invalid publisher destination path: #{path}. Folder  must already exists.")
      elsif not File.writable?(path)
        raise ArgumentError.new("Publisher destination path '#{path}' must be writable.")
      end
    end

    def older?(path, time)
      file_path = File.join(@base_path, path)
      return (not (File.exists?(file_path) and (File.new(file_path).mtime >= time)))
    end

    def differ?(path, hex_md5sum)
      file_path = File.join(@base_path, path)
      return (not (File.exists?(file_path) and \
                   (Digest::MD5.hexdigest(File.read(file_path)) == hex_md5sum)))
    end
    
    def save!(path, content, mtime=nil)
      file_path = File.join(@base_path, path)
      FileUtils.mkdir_p( File.dirname( file_path ) )
      File.open(file_path, "wb"){ |f| f.write(content) }
      File.utime(Time.new, mtime, file_path) if mtime
    end
  end


  class Publisher
    
    def initialize(context, site)
      @context = context
      @site = site
      @asset_witer = @page_writer = LocalFileWriter.new(@site.site_params.publish_location)
      if @site.site_params.publish_assets_location
        @asset_writer = LocalFileWriter.new(@site.site_params.publish_assets_location)
      end
    end
  
    def clenup_site_part_from_path(path)
      site_prefix = "/#{@site.name}"
      site_prefix_range = 0..(site_prefix.size-1)
      if path[site_prefix_range] == site_prefix
        path[site_prefix_range] = ''
      end
      path
    end

    # compute page path for location
    def compute_page_path(page_info)
      path = @context.url_for(page_info.merge(:only_path => true, 
                                              :skip_relative_url_root => true))
      clenup_site_part_from_path(path)
      # add index.html to root page path
      if path == ''
        path += '/index.html'
      end
      path
    end

    def compute_page_url(page_info)
      path = compute_page_path(page_info)
      if @site.site_params.published_url_prefix
        @site.site_params.published_url_prefix + path
      else
        path
      end
    end

    # Publish single page
    def publish(page_info, mtime=nil)
      mtime = normalize_time(mtime)
      page_path = compute_page_path(page_info)
      
      # Skip if page last_modified time is provided and file is older
      return if mtime and not @page_writer.older?(page_path, mtime)

      # Prepare component rendering input
      page_params = page_info.merge(:published => true)
      page_controller = page_params.delete(:controller)
      page_action = page_params.delete(:action).to_s

      # Register active publisher, for helpers so thay can notify it
      # about staic files and other stuff
      PublisherRegistrar.instance.publisher = self

      body = @context.render_component_as_string( :controller => page_controller,
                                                  :action => page_action,
                                                  :params => page_params )

      # Clear active component as soon as rendering component done
      PublisherRegistrar.instance.publisher = nil
      
      # Save and file only if differs, or was tested by modification time
      if not mtime and @page_writer.differ?(page_path, Digest::MD5.hexdigest(body))
        pmtime = mtime || 'unknown'
        if File.exists?(File.join(@page_writer.base_path, page_path))
          fmtime = File.new(File.join(@page_writer.base_path, page_path)).mtime
          @context.logger.info "Publisher: Updated file: #{page_path} (#{fmtime} < #{pmtime})"
        else
          @context.logger.info "Publisher: New file: #{page_path} (#{pmtime})"
        end
        @page_writer.save!(page_path, body, mtime)
        page_path
      end
    end

    # Publish assets folder
    def copy_assets_folder()
      theme_name = SiteParams.for_site(@site).theme || @site.name
      src_base_path = File.join(RAILS_ROOT, 'public', theme_name)
      
      def copy_folder(src_base_path, folder)
        folder_path = File.join(src_base_path, folder)
        Dir.new(folder_path).each do |file_name|
          if file_name != '.' and file_name != '..'
            file_path = File.join(folder_path, file_name)
            file_relative_path = File.join(folder, file_name)
            if Fil
              copy_folder(src_base_path, file_relative_path)
            elsif File.file? file_path
              mtime = File.new(file_path).mtime
              if @asset_writer.older?(file_relative_path, mtime)
                content = ''
                File.open(file_path, "rb"){ |f| content = f.read() }
                @asset_writer.save!(file_relative_path, content, mtime)
              end
            end
          end
        end
      end

      copy_folder(src_base_path, '')
    end

    # Method called by helper calulating assets path, to report every
    # assed used in template
    def report_asset_path path
      if ! @assets_paths
        @assets_paths = []
      end
      @assets_paths << path.dup
    end

    # Publish assets collected, while rendering pages
    def publish_assets(logger)
      src_base_path = File.join(RAILS_ROOT, 'public')
      for path in @assets_paths
        path.sub!(/\?[^\?]*$/ , '')
        src_path = File.join(src_base_path, path)
        mtime = File.new(src_path).mtime
        if @asset_writer.older?(path, mtime)
          content = ''
          File.open(src_path, "rb"){ |f| content = f.read() }
          @asset_writer.save!(path, content, mtime)
        end
      end
    end

    protected

    # Normalize time from various formats to unix type
    def normalize_time(time)
      if time.is_a? DateTime
        return time.to_time
      elsif time.is_a? ActiveSupport::TimeWithZone
        return time.time
      else 
        return time
      end
    end

  end


  class PublisherRegistrar
    include Singleton
    attr_accessor :publisher
  end


  def self.publisher_for_location(context, site)
    return Publisher.new(context, site)
  end

  def self.active_publisher()
    return PublisherRegistrar.instance.publisher
  end

end

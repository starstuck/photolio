module Site::BaseHelper

  protected

  def published_url_for(options={})
    if params[:published]
      options[:only_path] = true
    end

    path = url_for(options)
    
    if params[:published]
      path = url_for(options) 
      site_prefix = "/#{options[:site_name]}"
      site_prefix_range = 0..(site_prefix.size-1)
      if path[site_prefix_range] == site_prefix
        path[site_prefix_range] = ''
      end
      site = Site.find_by_name(options[:site_name])
      if site.site_params.published_url_prefix
        path = site.site_params.published_url_prefix + path
      end
    end
 
    path
  end

  # Calculate page path, arguments are in order, can be skipped:
  #   controller_name
  #   controller_context
  #   action_name
  #   action_context
  #   options that will be forwarde to underlying url_for command
  def page_path(site, controller, action, *args)
    
    site_controller_base_path = SiteIntrospector.introspect(site).theme_name
    options = {
      :format => 'html',
      :only_path => true,
      :controller => "/site/#{site_controller_base_path}/#{controller}",
      :site_name => site.name,
      :action => action }

    if args[-1].is_a? Hash
      options.update(args.pop)
    end

    # Extract arguments array in order of aperance
    if controller != 'site'
      arg = args.shift
      if arg
        if not arg.is_a? String 
          cinfo = SiteIntrospector.introspect(site).controller_info(controller)
          arg = [arg] if not is_a? Array
          arg = cinfo.context_packer.call(arg)
        end
        options[:controller_context] = arg
      end
    end
    arg = args.shift
    options[:action_context] = arg if arg
    published_url_for(options)
  end

  def page_url(site, controller, action, *args)
    if args[-1].is_a? Hash
      args[-1] = args[-1].merge(:only_path => false)
    else
      args << {:only_path => false}
    end
    page_path(site, controller, action, *args)
  end

  def compute_public_path(source, dir, ext=nil)
    for theme_path in SiteIntrospector.introspect(@site).theme_public_paths
      path = compute_public_path_without_photolio(source, "#{theme_path}/#{dir}", ext)
      filepath = path.sub(/^https?:\/\/[^\/]*/, '')
      if File.exists?( File.join(ActionView::Helpers::AssetTagHelper::ASSETS_DIR, filepath.split('?').first) )
        return fix_published_path(@site, path)
      end
    end
    raise ArgumentError.new("Asset '#{source}' not found in public path: #{path}" )
  end

  def compute_site_files_public_path(site, source, dir, ext=nil)
    if (site.id != @site.id and not @site.share_pool.include? site)
      raise RuntimeError.new("Access to #{site.name} assets files is denied")
    end    
    base_dir = "#{ModelExtensions::HasFile::BASE_FOLDER_NAME}/#{site.name}"
    path = compute_public_path_without_photolio(source, "#{base_dir}/#{dir}", ext)
    return fix_published_path(@site, path)
  end

  def fix_published_path(site, path)
    if params[:published]

      site_prefix = ""
      if host = ActionController::Base.asset_host
        site_prefix = host + site_prefix
      end
      site_prefix_range = 0..(site_prefix.size-1)
      if path[site_prefix_range] == site_prefix
        path[site_prefix_range] = ''
      end

      if Publisher.active_publisher
        Publisher.active_publisher.report_asset_path path
      end
      
      if site.site_params.published_assets_url_prefix
        path = site.site_params.published_assets_url_prefix + path
      end
    end
    path
  end

end

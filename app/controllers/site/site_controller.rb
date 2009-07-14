require 'publisher'
require 'generator'


class Site::SiteController < Site::BaseController

  def sitemap
    if params[:published]
      publisher = Publisher::publisher_for_location(self, @site)
    end

    @sitemap = self.class.site_pages(@site, in_sitemap_only = true).map do |item|
      if params[:published]
        item[:url] = publisher.compute_page_url(item[:loc])
      else
        item[:url] = url_for(item[:loc])
      end
      item
    end
    
    respond_to do |format|
      format.xml { render :template => 'site/sitemap', :layout => false}
    end
  end


  def self.site_pages(site, in_sitemap_only=false)
    pages = []
    theme_name = site.name
    
    controller_context_generators = {
      'photo' => Generator.new do |g|
        hidden_photo_ids = site.unassigned_photos.map{|x| x.id}
        for photo in site.photos
          if not hidden_photo_ids.include? photo.id
            g.yield({:site_name => site.name, :photo_id => photo.id})
          end
        end
      end,
      'topic' => Generator.new do |g|
        for topic in site.topics
          g.yield({:site_name => site.name, :topic_name => topic.name})
        end
      end,
      'gallery' => Generator.new do |g|
        for gallery in site.galleries
          g.yield({:site_name => site.name, :gallery_name => gallery.name})
        end
      end,
      'site' => [{:site_name => site.name}],
    }

    for controller_name in %w(site gallery topic photo)
      begin
        ext_module = eval("Site::#{theme_name.camelize}::#{controller_name.camelize}ControllerExtension")
      rescue NameError
        next
      end
      for method_name in ext_module.public_instance_methods.reject {|n| n.starts_with? 'page_info_for'}
        
        # Find page info
        info_method_name = "page_info_for_#{method_name}"
        dummy = Object.new
        dummy.extend(ext_module)
        if dummy.respond_to? info_method_name 
          info = dummy.send info_method_name
        else
          info = {}
        end
        info = { :priority => '0.5', :changefreq => 'weekly'}.update(info)

        # Skip pages no in sitemap if requested to do so
        if in_sitemap_only and info[:skip_sitemap]
          next
        end

        if in_sitemap_only or not info[:formats]
          page_formats = ['html']
        else
          page_formats = info[:formats]
        end

        context_generator = controller_context_generators[controller_name]
        for context in context_generator

          # TODO: add last_modified time calculation
          for format in page_formats
            info[:loc] = context.update( {
              :controller => "site/#{controller_name}",
              :action => 'dispatch',
              :method_name => method_name,
              :format => format,
            } )
            pages << info.dup
          end
        end
        
      end
    end
    pages
  end

end

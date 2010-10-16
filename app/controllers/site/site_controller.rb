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
    
    for cinfo in SiteIntrospector.introspect(site).controllers_infos
      for pinfo in cinfo.pages_infos

        # Skip pages no in sitemap if requested to do so
        if in_sitemap_only and not pinfo.in_sitemap?
          next
        end

        info = { :priority => '0.5', :changefreq => 'weekly'}.update(pinfo.sitemap_info)

        if in_sitemap_only or not pinfo.formats
          page_formats = ['html']
        else
          page_formats = pinfo.formats
        end

        if cinfo.context_iterator 
          c_contexts = cinfo.context_iterator.call(site)
        elsif cinfo.name == 'site'
          c_contexts = [nil]
        else
          next
        end

        for c_context in c_contexts

          base_location = {:site_name => site.name}
          base_location[:controller_context] = c_context if c_context
          if pinfo.context_iterator
            if cinfo.context_extractor
              c_context_vals = cinfo.context_extractor.call(site, c_context)
            end
            locations = pinfo.context_iterator.call(c_context_vals).map do |pc|
              location = base_location.dup
              location[:action_context] = pc
              location              
            end
          else
            locations = [base_location]
          end
          
          for location in locations
            # TODO: add last_modified time calculation
            for format in page_formats
              info[:loc] = location.merge(:controller => cinfo.path,
                                          :action => pinfo.name,
                                          :format => format)
              pages << info.dup
            end
          end

        end
        
      end
    end
    pages
  end

end

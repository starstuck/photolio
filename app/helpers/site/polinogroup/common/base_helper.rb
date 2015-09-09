module Site::Polinogroup::Common::BaseHelper

  def site_default_path(site)
    if site.is_a? String
      site = Site.find_by_name(site)
    end
    if site.name == 'polinogroup'
      return show_site_path(site)
    else
      menu = site.get_menu('galleries')
      return show_site_gallery_path(site, menu.menu_items[0].target)
    end
  end

  def brand_name(site)
    return site.name.sub(/^polino/, '')
  end

  def my_path(opts)
    my_controller_name = controller.class.to_s.underscore.sub(/_controller$/, '')
    options = {
      :format => 'html',
      :only_path => true,
      :controller => my_controller_name,
      :site_name => params[:site_name],
      :action => params[:action]
    }
    options[:action_context] = params[:action_context] if params.key? :action_context
    options[:controller_context] = params[:controller_context] if params.key? :controller_context      
    if opts.is_a? Hash
      options.update(opts)
    end
    return published_url_for(options)
  end

  def path_relative_to_loader(path)
    my_site_controller_name = controller.class.to_s.underscore.sub(/[^\/]+_controller$/, 'site')
    loader_path = published_url_for( :format => 'html',
                           :only_path => !( path =~ /http[s]?:\/\// ),
                           :site_name => params[:site_name],
                           :controller => my_site_controller_name,
                           :action => 'load')
    loader_base_path = loader_path.sub(/\/[^\/]+$/, '/')
    if path.index(loader_base_path) == 0
      path = path.slice(loader_base_path.size, path.size)
    end
    path
  end

  def my_path_relative_to_loader(opts)
    path_relative_to_loader(my_path(opts))
  end

  def _intro_images_paths_for_site(site)
    site.galleries.find_by_name('site_preview').photos.map{|x| photo_image_path(x, '800x800')}
  end

  def intro_images_paths(site)
    images = []
    if params[:site_name] == 'polinogroup'
      for sitename in %w(polinocollection polinobeauty polinofashion) 
        images += _intro_images_paths_for_site(Site.find_by_name(sitename))
      end
    else
      images = _intro_images_paths_for_site(site)
    end
    images
  end

  def loader_support_js()
    snippet = <<-EOS
      (function(){
        try{
          var ffMatch = navigator.userAgent.match(/(^| )Firefox\\\/([0-9]+)\\\.([0-9]+)\\\.[0-9\\\.]*( |$)/);
          if(ffMatch) {
            if( parseInt(ffMatch[2]) >= 3 ) return 1;
          }
          if(navigator.userAgent.match(/(^| )Safari\\\//)) return 1;
        }catch(e){};
        return 0;
      })()
    EOS
    return snippet.gsub(/\s+/, ' ')
  end

  def loader_redirect(site, path)
    path = path.sub(/\.(part)?html$/, '')
    javascript_tag "if(#{loader_support_js})window.location=\"#{load_site_path(site)}##{path}\";"
  end

  def loader_reverse_redirect()
    snippet = <<-EOS
      if(!#{loader_support_js}){
        var p = window.location.hash.match(/\#(.*)$/);
        if(p){
          p = p[1].replace(/\.parthtml$/, '.html');
          if(! p.match(/\\.[a-z]+$/)) p += '.html';
          window.location = p;
        }
      }
    EOS
    javascript_tag snippet.gsub(/\s+/, ' ')
  end

  def loader_with_intro(content_or_options_with_block, options={}, &block)
    htmltemplate =
      if block_given?
        options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
        capture(&block)
      else
        if content_or_options_with_block.is_a? Hash
          options = content_or_options_with_block
          ''
        else
          content_or_options_with_block
        end
      end

    jquery_path = path_to_javascript("jquery-1.4.2.min")
    scripts_paths = options[:scripts].map{|s| path_to_javascript s}

    jscontent = <<-EOS
      document.write('#{escape_javascript htmltemplate }');
      loader.bootstrap(#{array_or_string_for_javascript jquery_path});
      loader.addSlides(#{array_or_string_for_javascript options[:images]});
      loader.loadScripts(#{array_or_string_for_javascript scripts_paths});
    EOS
    
    if options[:gacode]
        jscontent += "\nloader.loadAnalytics(#{array_or_string_for_javascript options[:gacode]});"
    end

    output = javascript_include_tag('loader') + "\n" + javascript_tag(jscontent)
    if block_called_from_erb?(block)
      concat(output)
    else
      output
    end
  end

end

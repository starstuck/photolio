module Site::Polinogroup::Common::BaseHelper

  def site_default_path(site)
    menu = site.get_menu('galleries')
    show_site_gallery_path(site, menu.menu_items[0].target)
  end

  def brand_name(site)
    return site.name.sub(/^polino/, '')
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

    output = javascript_include_tag('loader') + "\n" + javascript_tag(jscontent)
    if block_called_from_erb?(block)
      concat(output)
    else
      output
    end
  end

end

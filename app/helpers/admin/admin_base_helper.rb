module ActionView::Helpers::AssetTagHelper
  alias_method :compute_public_path_without_admin, :compute_public_path
end

module Admin::AdminBaseHelper

  def remote_callback(options={})
    options[:with] ||= "'id=' + encodeURIComponent(element.id)"
    options[:loading] ||= "Element.update('#{options[:update]}', '<td style=\"width: 100px;\">#{loading_tag}</td>')"
    %(function(event){var element = Event.element(event); #{remote_function(options)}})
  end

  def protomenu_tag(selector, options={})
    javascript_tag(protomenu_js(selector, options))
  end

  # Build javascript tag, that loads tinymce to all textareas on page
  def load_tinymce_tag
    javascript_tag <<-EOS
      document.write(unescape("%3cscript src='#{javascript_path('/tiny_mce/tiny_mce')}' type='text/javascript'%3E%3C/script%3E"));
      add_onload_handler(function(){ tinyMCE.init({mode: 'textareas', theme: 'advanced',}); });
    EOS
  end

  def protomenu_js(selector, options={})
    options[:selector] = selector
    options[:menuItems] = '[' + options[:menuItems].map{|x| options_for_javascript(x)}.join(', ') + ']'
    %(new Proto.Menu(#{options_for_javascript(options)});)
  end

  def compute_photo_path(photo)
    compute_public_path_without_admin(photo.file_name, "#{photo.site.name}/photos")
  end

  def compute_photo_thumbnail_path(size, photo)
    compute_public_path_without_admin(photo.thumbnail_path(size), "#{photo.site.name}/photos")
  end


  #
  # Main template slots customization 
  #

  def page_title
    'Photolio'
  end

  protected

  def compute_public_path(source, dir, ext=nil)
    compute_public_path_without_site(source, "admin/#{dir}", ext)
  end

end

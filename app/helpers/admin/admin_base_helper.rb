module Admin::AdminBaseHelper

  def remote_callback(options={})
    options[:with] ||= "'id=' + encodeURIComponent(element.id)"
    options[:loading] ||= "Element.update('#{options[:update]}', '<td style=\"width: 100px;\">#{loading_tag}</td>')"
    %(function(event){var element = Event.element(event); #{remote_function(options)}})
  end

  def protomenu_tag(selector, options={})
    javascript_tag(protomenu_js(selector, options))
  end

  def protomenu_js(selector, options={})
    options[:selector] = selector
    options[:menuItems] = '[' + options[:menuItems].map{|x| options_for_javascript(x)}.join(', ') + ']'
    %(new Proto.Menu(#{options_for_javascript(options)});)
  end

  #
  # Main template slots customization 
  #

  def extra_head_tags
    [ stylesheet_link_merged( :admin ),
      javascript_include_merged( :admin ),
      javascript_include_tag( '/tiny_mce/tiny_mce' )
      ].join("\n")
  end

  def brand_name
    'admin'
  end
end

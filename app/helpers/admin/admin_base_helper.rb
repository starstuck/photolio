module Admin::AdminBaseHelper

  def extra_stylesheets_tags
    stylesheet_link_tag 'adminpanel'
  end

  def brand_name
    'admin'
  end
end

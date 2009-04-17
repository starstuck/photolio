# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def site_default_path(site)
    show_site_gallery_path(site, site.galleries_in_order.first)
  end

  def compute_photo_path(photo)
    compute_public_path(photo.file_name, 'photos')
  end

  def compute_photo_thumbnail_path(size, photo)
    compute_public_path(photo.thumbnail_path(size), 'photos')
  end

  def loading_tag
    loaging_image_tag = image_tag(path_to_image('loading.gif'))
    "<p style=\"text-align: center\">#{loaging_image_tag}"
  end

  #
  # Slots used by main template. 
  #
  # You can overwrite these in your helpers, to customize layout used fot
  # particular controller
  #
  def extra_head_tags
    nil
  end

  def page_title
    "#{@site.name}"
  end
  
  def brand_name
    nil
  end

end

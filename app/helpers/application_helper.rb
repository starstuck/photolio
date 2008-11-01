# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def compute_photo_path(photo)
    compute_public_path(photo.file_name, 'photos') 
  end

  def extra_stylesheets_tags
    nil
  end

  def page_title
    "Polino Studio #{brand_name}"
  end
  
  def brand_name
    nil
  end

  def loading_tag
    loaging_image_tag = image_tag(path_to_image('loading.gif'))
    "<p style=\"text-align: center\">#{loaging_image_tag}"
  end
end

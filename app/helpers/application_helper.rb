# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def published_site_gallery_path(site, gallery, format='html', options={})
    if site.name == 'studio'
      published_studio_gallery_path(gallery.name, format, options)
    else
      published_brand_site_gallery_path(site.brand, site.name, gallery.name, format, options)
    end
  end

  def published_site_photo_path(site, photo, format='html', options={})
    if site.name == 'studio'
      published_studio_photo_path(photo.id, format, options)
    else
      published_brand_site_photo_path(site.brand, site.name, photo.id, format, options)
    end
  end

  def published_site_topic_path(site, topic, format='html', options={})
    if site.name == 'studio'
      published_studio_topic_path(topic.name, format, options)
    else
      published_brand_site_topic_path(site.brand, site.name, topic.name, format, options)
    end
  end

  def site_default_path(site)
    published_site_gallery_path(site, site.galleries_in_order.first)
  end

  def global_default_path
    default_site = Site.find(:first, :conditions => {:name => 'studio'})
    site_default_path(default_site)
  end

  class PhotoTag < ActionView::Helpers::AssetTagHelper::ImageTag
    DIRECTORY = 'photos'.freeze    
  end

  def compute_photo_path(photo)
    PhotoTag.new(self, @controller, photo.file_name, include_host=false).public_path
  end

  def compute_photo_thumbnail_path(size, photo)
    PhotoTag.new(self, @controller, photo.thumbnail_path(size), include_host=false).public_path
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
    "Polino Studio #{brand_name}"
  end
  
  def brand_name
    nil
  end

end

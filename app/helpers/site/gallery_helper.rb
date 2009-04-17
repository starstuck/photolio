module Site::GalleryHelper

  def total_gallery_items_width(gallery)
    #  Values below are based on CSS styles
    separator_width = 100
    margin_width = 4
    
    total = 0
    for item in gallery.gallery_items
      if item.is_a? GalleryPhoto
        total += (item.photo.width.to_f / item.photo.height * 400).to_i
      elsif item.is_a? GallerySeparator
        total += separator_width
      end
      total += margin_width
    end

    total
  end

end

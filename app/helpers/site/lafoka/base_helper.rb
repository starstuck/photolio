module Site::Lafoka::BaseHelper

  def galleries_major_labels
    cached_galleries_menu_labels.map{ |n|
      n.split(':')[0].strip
    }.uniq
  end

  def gallery_major_label
    for item in cached_galleries_menu_items
      if item.target_id == @gallery.id
        return item.label_or_target_title.split(':')[0].strip
      end
    end
    nil
  end

  def default_gallery_for_major_label(major_label)
    for gallery_label in cached_galleries_menu_labels
      if gallery_label.split(':')[0].strip == major_label
        return cached_galleries_menu_items.reject{ |x| 
          x.label_or_target_title != gallery_label
        }[0].target
      end
    end
    nil
  end

  protected

  def cached_galleries_menu_items
    @cached_galleries_menu_items ||= @site.get_menu('galleries').menu_items
  end

  def cached_galleries_menu_labels
    @cached_galleries_menu_labels ||= cached_galleries_menu_items.map do |i|
      i.label_or_target_title
    end
  end

end

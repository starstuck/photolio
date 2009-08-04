module Site::Lafoka::GalleryHelper

  def galleries_minor_labels_and_objects
    unless @cached_galleries_menu_items
      for i in cached_galleries_menu_items.reject
        if i.target.id == @gallery.id
          major_label = i.label_or_target_title.split(':')[0].strip
          break
        end
      end

      @cached_galleries_minor_labels_and_objects = cached_galleries_menu_items.map{ |item|
        parts = item.label_or_target_title.split(':')
        major = parts[0].strip
        if major_label and major == major_label
          [parts[1..-1].join(':').strip, item.target]
        else
          nil
        end
      }.reject{|x| x.nil? or x[0] == ''}
    end
    @cached_galleries_minor_labels_and_objects
  end

  # Get previous gallery by minor label, 
  def prev_gallery_by_minor_label
    previous = nil
    for gallery_minor, target in galleries_minor_labels_and_objects
      if target.id == @gallery.id
        return previous
      end
      previous = target
    end
    nil
  end

  # Get next gallery by minor label, 
  def next_gallery_by_minor_label
    previous = nil
    for gallery_minor, target in galleries_minor_labels_and_objects
      if previous and previous.id == @gallery.id
        return target
      end
      previous = target
    end    
    nil
  end

end

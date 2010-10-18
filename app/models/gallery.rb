class Gallery < ActiveRecord::Base

  has_attachment
  acts_as_named_content
  acts_as_menu_item_target

  belongs_to :site
  has_many :gallery_items, :order => 'position',
           :dependent => :destroy # Access for many-to-many through 
                                  # model for management (ordering)
  has_and_belongs_to_many :photos, :order => 'position', :uniq => true, :readonly => true

  validates_presence_of :site
  validates_length_of :name, :maximum => 255
  validates_length_of :title, :maximum => 255
 

  # Add existing GalleryItem object to this gallery (maintain association)
  def add_item(item, position=nil)
    item.gallery = self

    # Store photos order, before adding new record, for futher order maintance
    items_order = gallery_item_ids
    
    # Clear orders list from occurance of item we are currently moving
    # Required if readding item in the same gallery
    if item.id
      i = 0
      items_order.reject! do |x|
        result = false
        if x == item.id
          position -= 1 if position and position > i
          result = true
        end
      i += 1
      result
      end
    end

    # force reread gallery_item collection before reordering
    item.save!   
    gallery_items(true) 

    if position
      items_order.insert(position, item.id)
    else
      items_order << item.id
    end    
    reorder_items(items_order)
  end


  # Assign photo to gallery.
  #
  # If other galleries in the same site usees this photo, the photo will be
  # unassigned form them.
  # If photo is already assigned to gallery, it will be only repositioned
  # Please note, that when readding the same photo in gallery, indexes are 
  # calculated on photos before move
  def add_photo(photo, position = nil, copy = false)
    unless photo.is_a? Photo
      raise(ArgumentError, 'Expecting Photo instance instead of : #{photo.inspect}') 
    end

    # Remove photo from other galleries, except the one we are adding photo to
    other_galleries_photos = photo.gallery_items.find(:all,
                      :conditions => ['gallery_id in (?)', site.gallery_ids])
    already_exists = false
    other_galleries_photos.each do |item| 
      if item.gallery_id != self.id
        if not copy
          item.gallery.remove_photo(photo)
        end
      else
        already_exists = item
      end
    end
    
    # Crate join record, only if not exists
    unless already_exists
      new_item = GalleryPhoto.new(:photo => photo)
    else
      new_item = already_exists
    end

    add_item(new_item, position)
  end
               
  # Add gallery separator on slected position
  def add_separator(position = nil)
    # Add separator only if no separator already exists on the ssame
    # position, or position before
    position
    unless (position == nil or position == 0 or position >= gallery_items.size or
        gallery_items[position].is_a? GallerySeparator or
        gallery_items[position-1].is_a? GallerySeparator)
      new_item = GallerySeparator.new
      add_item(new_item, position)
    end
  end

  # Unassign photo from gallery
  def remove_photo(photo)
    unless photo.is_a? Photo
      raise(ArgumentError, 'Expecting Photo instance instead of : #{photo.inspect}') 
    else
      gallery_items.find(:all, :conditions => {'photo_id' => photo.id}).each do |gp|
        gp.destroy
      end
    end
  end

  # Reorder gallery photos to match order of photo_ids
  def reorder_items(item_ids)
    items_by_id = Hash[*(gallery_items.map{|item| [item.id, item]}.flatten)]

    # Update join records position to match photo_ids order
    i = 0
    item_ids.each do |item_id|
      if items_by_id.key? item_id
        items_by_id[item_id].position = i
        items_by_id[item_id].save!
        items_by_id.delete(item_id)
        i += 1
      end
    end

    # Now update all items, not mentioned in parameter photo_ids
    items_by_id.values.sort{|x, y| x.position <=> y.position}.each do |item|
      item.position = i
      item.save!
      i += 1
    end

  end
  
end

class Gallery < ActiveRecord::Base

  belongs_to :site
  has_many :galleries_photos, :order => 'position',
           :dependent => :destroy # Access for many-to-many through 
                                  # model for management (ordering)
  has_and_belongs_to_many :photos, :order => 'position', :uniq => true, :readonly => true

  validates_presence_of :site
  validates_length_of :name, :maximum => 16
  validates_uniqueness_of :name, :scope => 'site_id'
  validates_length_of :title, :maximum => 255, :allow_nil => true

  # Assign photo to gallery.
  #
  # If other galleries in the same site usees this photo, the photo will be
  # unassigned form them.
  # If photo is already assigned to gallery, it will be only repositioned
  # Please note, that when readding the same photo ingallery, indexes are 
  # calculated on photos before move
  def add_photo(photo, position=nil)
    unless photo.is_a? Photo
      raise(ArgumentError, 'Expecting Photo instance instead of : #{photo.inspect}') 
    end

    # Remove photo from other galleries, except the one we are adding photo to
    other_galleries_photos = photo.galleries_photos.find(:all,
                      :conditions => ['gallery_id in (?)', site.gallery_ids])
    already_exists = false
    other_galleries_photos.each do |gp| 
      if gp.gallery_id != self.id
        gp.gallery.remove_photo(photo)
      else
        already_exists = gp
      end
    end
    
    # Store photos order, before creating new record, for futher order maintance
    photos_order = galleries_photos.map{|gp| gp.photo_id}

    # Crate join record, only if not exists
    unless already_exists
      new_gp = galleries_photos.build(:photo => photo)
      new_gp.save!
    else
      new_gp = already_exists
    end

    # Reorder photos, acording to position,
    # If no position argument provided,  we still must run reorder method
    # to set position in new record
    
    # Clear orders list from occurance of photo we are currently moving
    # Required if readding photo in the same gallery
    i = 0
    photos_order.reject! do |x|
      result = false
      if x == new_gp.photo_id
        position -= 1 if position and position > i
        result = true
      end
      i += 1
      result
    end
    
    if position
      photos_order.insert(position, new_gp.photo_id)
      #raise 'Inserting into position: ' + position.to_s
    else
      photos_order << new_gp.photo_id
    end
    galleries_photos(true) # force reread galleries_photos  collection before reordering
    reorder_photos(photos_order)
  end

  # Unassign photo from gallery
  def remove_photo(photo)
    unless photo.is_a? Photo
      raise(ArgumentError, 'Expecting Photo instance instead of : #{photo.inspect}') 
    else
      galleries_photos.find(:all, :conditions => {'photo_id' => photo.id}).each do |gp|
        gp.destroy
      end
    end
  end

  # Reorder gallery photos to match order of photo_ids
  def reorder_photos(photo_ids)

    logger.info "+++ Reordering photos with: #{photo_ids.inspect}"

    galleries_photos_by_photo_id = Hash[*(galleries_photos.map{|gp| [gp.photo_id, gp]}.flatten)]

    # Update join records position to match photo_ids order
    i = 0
    photo_ids.each do |photo_id|
      if galleries_photos_by_photo_id.key? photo_id
        galleries_photos_by_photo_id[photo_id].position = i
        galleries_photos_by_photo_id[photo_id].save!
        galleries_photos_by_photo_id.delete(photo_id)
        i += 1
      end
    end

    # Now update all photos, not mentioned in parameter photo_ids
    galleries_photos_by_photo_id.values.sort{|x, y| x.position <=> y.position}.each do |gp|
      gp.position = i
      gp.save!
      i += 1
    end

  end
  
end

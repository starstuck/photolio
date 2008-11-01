class Site < ActiveRecord::Base

  BRANDS = ['artists', 'models']

  has_many :galleries, :dependent => :destroy, :order => 'name' 
  has_many :photos, :dependent => :destroy, :order => 'file_name'
  has_many :topics, :dependent => :destroy, :order => 'title'

  validates_length_of :name, :in => 3..255
  validates_uniqueness_of :name
  validates_inclusion_of :brand, :in => BRANDS, :allow_blank => true

  def self.brands_selection
    return [nil] + BRANDS
  end

  # List of photos not assigned to any gallery
  def unassigned_photos
    assigend_photos_ids = {}
    for gal in galleries
      for gp in gal.galleries_photos
        assigend_photos_ids[gp.photo_id] = true unless assigend_photos_ids.key? gp.photo_id
      end
    end
    return Photo.find(photos.reject{|x| assigend_photos_ids.key? x.id}, 
                      :order => 'file_name')
  end

end

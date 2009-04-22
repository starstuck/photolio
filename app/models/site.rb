class Site < ActiveRecord::Base

  BRANDS = ['artists', 'models']
  
  class << self
    attr_accessor :publish_remote_location
  end

  has_many :galleries, :dependent => :destroy, :order => 'name' 
  has_many :photos, :dependent => :destroy, :order => 'file_name'
  has_many :topics, :dependent => :destroy, :order => 'title'
  has_and_belongs_to_many :users, :order => 'name, login', :uniq => true

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
      for item in gal.gallery_items
        assigend_photos_ids[item.photo_id] = true unless assigend_photos_ids.key? item.photo_id
      end
    end
    return Photo.find(photos.reject{|x| assigend_photos_ids.key? x.id}, 
                      :order => 'file_name')
  end

  # Get gallereis, sorted by  titel in user firendly way (numbers are treated as numbers)
  def galleries_in_order(limit_by_display_in_index = true)
    gals = galleries
    gals.reject!{ |g| not g.display_in_index } if limit_by_display_in_index
    gals.sort do |x, y|
      # Sort galeries like numbers if name starts from digits (2 is lower then 10)
      xn = x.name
      yn = y.name
      x_is_num = (xn.to_i != 0 or xn[0] == '0')
      y_is_num = (yn.to_i != 0 or yn[0] == '0')
      
      result = begin
                 if x_is_num and y_is_num
                   xn.to_i <=> yn.to_i
                 elsif x_is_num
                   -1
                 elsif y_is_num
                   1
                 else
                   nil
                 end
               end
          
      if result and result != 0
        result
      else
        xn <=> yn #falback to string comparision
      end        
    end
  end

end

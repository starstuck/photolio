class Gallery < ActiveRecord::Base

  belongs_to :site
  has_many :galleries_photos, :dependent => :destroy # Access for many-to-many through 
                                                     # model for management (ordering)
  has_and_belongs_to_many :photos, :order => 'position', :uniq => true, :readonly => true

  validates_presence_of :site
  validates_length_of :name, :maximum => 16
  validates_uniqueness_of :name, :scope => 'site_id'
  validates_length_of :title, :maximum => 255, :allow_nil => true

end

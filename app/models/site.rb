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

end

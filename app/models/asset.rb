class Asset < ActiveRecord::Base

  has_file
  acts_as_attachment
  
  belongs_to :site

  validates_length_of :label, :maximum => 255, :allow_nil => true
  validates_length_of :image_alt, :maximum => 255, :allow_nil => true

  set_files_folder 'assets'

end


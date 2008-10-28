require 'ftools'


class Photo < ActiveRecord::Base

  PHOTOS_ROOT = "#{RAILS_ROOT}/public/photos"

  has_many :galleries_photos, :dependent => :destroy
  has_and_belongs_to_many :galleries, :readonly => true # Simple access skiping assoc table
  belongs_to :site # Site ehere photo has been imported. Afterwards it can be 
                   # placed in different galleries and differnt sites
  has_many :photo_participants, :dependent => :destroy
  has_many :photo_keywords, :dependent => :destroy

  before_validation_on_create :update_file_name
  after_save :write_file
  after_destroy :delete_file

  attr_readonly :file_name

  validates_length_of :file_name, :maximum => 255, :allow_blank => false
  validates_uniqueness_of :file_name
  validates_presence_of :site
  validates_length_of :title, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 255, :allow_nil => true
  validates_associated :photo_participants, :photo_keywords

  def file=(file_data)
    @file_data = file_data
  end

  # We can set file name after photo site is set
  def update_file_name
    if @file_data
      self.file_name = "#{site.name}/#{@file_data.original_filename}"
    end      
  end

  def write_file
    if @file_data
      File.makedirs("#{PHOTOS_ROOT}/#{site.name}")
      File.open("#{PHOTOS_ROOT}/#{file_name}", "w") do |f|
        f.write(@file_data.read)
      end
    end
  end

  # Delete file ony if no other foto uses it
  def delete_file
    if Photo.count(:conditions => {'file_name' => file_name}) <= 1
      FileUtils.rm_rf("#{PHOTOS_ROOT}/#{file_name}")
    end
  end

end

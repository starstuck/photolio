require 'ftools'


class Photo < ActiveRecord::Base

  PHOTOS_ROOT = "#{RAILS_ROOT}/public/photos"

  has_many :gallery_items, :dependent => :destroy
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
  
  # Get path for thumbnail, in selected size. If thumbnail is not generated yet, it will be created
  def thumbnail_path(height)
    File.makedirs("#{PHOTOS_ROOT}/_cache/h#{height}/#{File.dirname(file_name)}")
    thumb_path = "#{PHOTOS_ROOT}/_cache/h#{height}/#{file_name}"
    unless File.exists? thumb_path
      system("convert #{PHOTOS_ROOT}/#{file_name} -resize x#{height} -quality 75% #{thumb_path}")
    end
    "_cache/h#{height}/#{file_name}"
  end

  # Update keywords values from array of hashes, having keywords data
  # Keywords are matched by name
  def update_keywords(keywords_data)
    old_keywords_by_name = Hash[*(photo_keywords.map{|k| [k.name, k]}.flatten)]
    
    # update existing keywords and create new ones
    for kw_data in keywords_data
      if old_keywords_by_name.key? kw_data['name']
        kw = old_keywords_by_name.delete(kw_data['name'])
        kw.update_attributes(kw_data)
      else
        if kw_data['name'] != ''
          unless photo_keywords.build(kw_data).save
            errors.add 'photo_keywords', "invalid record data: #{p_data.inspect}"
          end
        end
      end
    end

    # delete keywords not present in keywords_data
    for kw in old_keywords_by_name.values
      photo_keywords.delete(kw)
    end
  end

  # Update participants values from array of hashes, having participans data
  # Participants are matched by roel and name
  def update_participants(participants_data)
    old_participants_by_role_name = Hash[*(photo_participants.map{|p| ["#{p.role}:#{p.name}", p]}.flatten)]
    
    # update existing participants, an create new ones
    new_participants_data = []
    for p_data in participants_data
      identifier = "#{p_data['role']}:#{p_data['name']}"
      if old_participants_by_role_name.key? identifier
        p = old_participants_by_role_name.delete(identifier)
        p.update_attributes(p_data)
      else
        if p_data['name'] != '' and p_data['role'] != ''
          unless photo_participants.build(p_data).save
            errors.add 'photo_participants', "invalid record data: #{p_data.inspect}"
          end
        end
      end
    end
    
    # delete all obsolete participant records
    for p in old_participants_by_role_name.values
      photo_participants.delete(p)
    end
  end


end

require 'find'
require 'ftools'
require 'mini_magick_utils'


class Photo < ActiveRecord::Base

  has_many :gallery_items, :dependent => :destroy
  has_and_belongs_to_many :galleries, :readonly => true # Simple access skiping assoc table
  belongs_to :site # Site ehere photo has been imported. Afterwards it can be 
                   # placed in different galleries and differnt sites
  has_many :photo_participants, :dependent => :destroy
  has_many :photo_keywords, :dependent => :destroy

  before_validation_on_create :update_file_name_and_metadata
  after_save :write_file
  after_destroy :delete_file

  # File name is full file location relative to photos base folder
  attr_readonly :file_name

  validates_length_of :file_name, :maximum => 255, :allow_blank => false
  validates_uniqueness_of :file_name, :scope => :site_id
  validates_presence_of :site
  validates_length_of :title, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 255, :allow_nil => true
  validates_associated :photo_participants, :photo_keywords
  validates_length_of :format, :maximum => 8
  validates_numericality_of :width, :only_integer => true
  validates_numericality_of :height, :only_integer => true

  def file=(file_data)
    @uploaded_file = file_data
  end

  def photos_folder
    "#{RAILS_ROOT}/public/#{site.name}/photos"
  end
  
  # Resized photos path prefix relative to master photos folder
  def resized_path_prefix
    "_resized"
  end

  def resized_photos_folder
    "#{photos_folder}/#{resized_path_prefix}"
  end

  # We can set file name after photo site is set
  def update_file_name_and_metadata
    if @uploaded_file
      self.file_name = "#{@uploaded_file.original_filename}"
      image = MiniMagick::Image.from_blob(@uploaded_file.read, self.file_name.split('.')[-1])
      photo_store_size = site.site_params.photo_store_size
      if not image.match_max_size(photo_store_size)
        image.resize(photo_store_size)
      end
      self.width = image[:width]
      self.height = image[:height]
      self.format = image[:format]
      @file_data = image.to_blob
    end      
  end

  def write_file
    if @file_data
      File.makedirs("#{photos_folder}")
      File.open("#{photos_folder}/#{file_name}", "w") do |f|
        f.write(@file_data)
      end
    end
  end

  # Delete file ony if no other foto uses it
  def delete_file
    if Photo.count(:conditions => {'file_name' => file_name}) <= 1
      # Remove photo data
      FileUtils.rm_rf("#{photos_folder}/#{file_name}")
      # Remove resized thumbnails
      FileUtils.rm_rf("#{resized_path_prefix}/#{file_name_without_ext}")
    end
  end  
  
  # Get fiel name (with path prefix) for resized version of photo. 
  # If resized thumbnail is not generated yet, it will be created.
  # Size is supposed to be in format <width>x<height>. If one is missing,
  # photo will be resized to preserve aspect ratio.
  def resized_file_name(size)
    r_width, r_height = size.split('x')
    
    if r_width.to_s.empty? and not r_height.to_s.empty?
      r_width = (r_height.to_f * width / height).to_i
    elsif r_height.to_s.empty? and not r_width.to_s.empty?
      r_width = (r_width.to_f * height / width).to_i
    elsif r_height.to_s.empty? and r_width.to_s.empty?
      return file_name
    end

    resized_file_name = "#{resized_path_prefix}/#{file_name_without_ext}/#{r_width}x#{r_height}"
    if not file_name_ext.empty?
      resized_file_name += ".#{file_name_ext}"
    end
    resized_file_path = "#{photos_folder}/#{resized_file_name}"
    File.makedirs(File.dirname(resized_file_path))

    if ( not File.exists? resized_file_path ) and File.exists? "#{photos_folder}/#{file_name}"
      mm = MiniMagick::Image.from_file("#{photos_folder}/#{file_name}")
      mm.resize( size, '-quality', '85%' )
      mm.write(resized_file_path)
    end
    
    resized_file_name
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

  # Build photo alt text cosisting of title, participants, keywords and description
  def alt_text
    res = []
    res << title if title and title.size > 0
    photo_participants.each{|p| res << "#{p.role}: #{p.name}"}
    photo_keywords.each{|k| res << k}
    res << title if description and description.size > 0
    res.join('; ')
  end

  private

    
  def file_name_ext
    ext = file_name.split('.')[-1]
    if ext == file_name or ext.include? '/' or ext.include? '\\'
      ''
    else
      ext
    end
  end

  def file_name_without_ext
    file_name[0..-(2 + file_name_ext.length)]
  end

end

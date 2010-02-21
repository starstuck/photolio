class Photo < ActiveRecord::Base

  has_file
  acts_as_attachment

  has_many :gallery_items, :dependent => :destroy
  has_and_belongs_to_many :galleries, :readonly => true # Simple access skiping assoc table
  belongs_to :site # Site ehere photo has been imported. Afterwards it can be 
                   # placed in different galleries and differnt sites
  has_many :photo_participants, :dependent => :destroy
  has_many :photo_keywords, :dependent => :destroy

  before_validation_on_create :resize_on_upload

  validates_presence_of :site
  validates_length_of :title, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 255, :allow_nil => true
  validates_associated :photo_participants, :photo_keywords

  set_files_folder 'files/photos'

  
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
    photo_keywords.each{|k| res << k.name}
    res << title if description and description.size > 0
    res.join('; ')
  end

  alias_method :image_alt, :alt_text # for compatybility with attachmentt object

  protected

  def resize_on_upload
    if @uploaded_data
      photo_store_size = site.site_params.photo_store_size
      if photo_store_size
        image = MiniMagick::Image.from_blob(@uploaded_data, file_name_extension)
        if not image.match_max_size(photo_store_size)
          image.resize(photo_store_size)
          @uploaded_data = image.to_blob
          update_image_meta
        end
      end
    end      
  end

end

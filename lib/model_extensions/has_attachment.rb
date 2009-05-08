module ModelExtensions::HasAttachment

  def has_attachment
    class_eval do
      extend ClassMethods
      include InstanceMethods
      
      has_many(:attachment_slots, :as => :having_attachment, 
               :dependent => :destroy, :order => 'name')
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    # Shortcut method for getting attachment object by slot name
    def get_attachment(name)
      slot = attachment_slots.find(:first, 
                                   :conditions => {:name => name}, 
                                   :include => :attachment)
      if slot
        slot.attachment
      end
    end

    # Prefered shortcut for setting attachment in slot
    def set_attachment(name, attachment)
      slot = attachment_slots.find_or_initialize_by_name(name)
      slot.attachment = attachment
      slot.save!
    end

    # Preferet shortcut for unlinking attachment from slot
    def destroy_attachment(name)
      slot = attachment_slots.find_by_name(name)
      slot.destroy if slot
    end

    # List of attachments, event with empty slots
    def attachment_slots_with_empty(refresh=false)
      slots_by_name = {}
      for slot in attachment_slots(refresh)
        slots_by_name[slot.name] = slot
      end
      for definition in site.site_params.attachment_slots(self).values
        if not slots_by_name.key? definition.name
          slots_by_name[definition.name] = AttachmentSlot.new(:name => definition.name,
                                                              :having_attachment => self)
        end 
      end
      slots_by_name.sort.map{|x| x[1]}
    end

    # Update attachments slots information form dict ov values.
    def update_attachment_slots(slots_data)
      for slot in attachment_slots_with_empty
        if slots_data.key? slot.name
          if( slots_data[slot.name].key? :attachment_id and 
              slots_data[slot.name][:attachment_id] and
              not slots_data[slot.name][:attachment_id].to_s.empty? )
            slot.attachment_type = slots_data[slot.name][:attachment_type]
            slot.attachment_id = slots_data[slot.name][:attachment_id]
            if slot.valid?
              slot.save!
            else
              slot.errors.each_full do |message|
                errors.add("attachment_slots", "Attachment '#{slot.name}' error: #{message}")
              end
            end
          else
            destroy_attachment(slot.name)
          end
        end
      end
    end

  end

end

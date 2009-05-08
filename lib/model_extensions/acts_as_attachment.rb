module ModelExtensions::ActsAsAttachment

  def acts_as_attachment
    class_eval do
      extend ClassMethods
      include InstanceMethods
      
      has_many :attachment_slots, :as => :attachment, :dependent => :destroy
    end
  end


  module ClassMethods
  end


  module InstanceMethods
  end

end

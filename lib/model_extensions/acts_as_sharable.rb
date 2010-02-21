module ModelExtensions::ActsAsSharable

  def acts_as_sharable
    class_eval do
      extend ClassMethods
      include InstanceMethods
      
      has_many :attachment_slots
    end
  end


  module ClassMethods
  end


  module InstanceMethods
  end

end

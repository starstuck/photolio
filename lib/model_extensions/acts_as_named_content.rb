# -*- coding: utf-8 -*-
module ModelExtensions::ActsAsNamedContent

  NAME_TRANSTABLE = [ 'ÀÁÂÃÄÅĄÇĆÈÉÊËĘÌÍÎÏÐŁÑŃÒÓÔÕÖ×ØŚÙÚÛÜÝŻŹàáâãäåąçèéêëęìíîïłñńòóôõöøśùúûüýżź', 
                      'AAAAAAACCEEEEEIIIIDLNNOOOOOxOSUUUUYZZaaaaaaaceeeeeiiiilnnoooooosuuuuyzz' ]
  NAME_TRANSMAP = Hash[ * NAME_TRANSTABLE.map{|s| s.split('')}.transpose.flatten ]
  NAME_CLEANUP_REGEXP = /[^a-z0-9]+/


  def acts_as_named_content
    class_eval do
      extend ClassMethods
      include InstanceMethods

      attr_protected :name
      
      validates_length_of :name, :maximum => 255
      validates_uniqueness_of :name, :scope => ['site_id']

      before_validation :update_name
      
    end
  end


  module ClassMethods
  end


  module InstanceMethods

    def name=(new_name)
      raise(ArgumentError, 'Name can not be manualy updated')
    end

    def update_name
      write_attribute(:name, compute_name_for(title))
    end

    def compute_name_for(title)
      chars = title.split('').collect do |c|
        ( NAME_TRANSMAP.key? c ) ? NAME_TRANSMAP[c] : c 
      end
      base_name = chars.join.downcase.gsub( NAME_CLEANUP_REGEXP, '_' )
      
      # If name exists, add numbers until unique name is found
      bcond = ["site_id = ? AND name LIKE ?",
                       site.id, "#{base_name}%"]
      if self.id
        bcond[0] += ' AND id <> ?'
        bcond << self.id
      end
      blockers = self.class.find(:all, :conditions => bcond).map{|t| t.name}

      if blockers.size > 0
        new_name = base_name
        i = 1
        #raise  ("Testing collection: " + site)      titles = 
        while blockers.include? new_name
          new_name = "#{base_name}_#{i}"
          i += 1
        end
        return new_name
      else
        return base_name
      end
    end

  end

end

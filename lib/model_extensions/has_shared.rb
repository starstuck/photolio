module ModelExtensions::HasShared

  def has_shared association_id, options = {}
    association_name = association_id.to_s
    association_class_name = association_name.classify
    if association_name < self.table_name
      join_table = "#{association_name}_#{self.table_name}"
    else
      join_table = "#{self.table_name}_#{association_name}"
    end
    item_foreign_key = association_name.singularize + '_id'
    owner_foreign_key = self.table_name.singularize + '_id'
    finder_sql = "SELECT #{association_name}.* FROM #{association_name}" +
      " LEFT OUTER JOIN #{join_table}" +
      "  ON #{association_name}.id = #{join_table}.#{item_foreign_key}" +
      " WHERE #{join_table}.#{owner_foreign_key} = \#{id}" +
      "  OR #{association_name}.#{owner_foreign_key} = \#{id}"
    if options[:order]
      finder_sql += " ORDER BY #{options[:order]}"
    end
    
    class_eval do
      has_many( "owned_#{association_name}".to_sym, 
                options.merge({ :class_name => association_class_name }) )
      has_and_belongs_to_many( "external_#{association_name}".to_sym,
                               :class_name => association_class_name,
                               :order => options[:order] )
      has_many( association_name,
                :readonly => true,
                :finder_sql => finder_sql )

      include InstanceMethods
    end

    class_eval <<-EOS
      def find_available_external_#{association_name} options={}
        find_available_external_for_share( "#{association_name}", options )
      end
    EOS
  end


  module InstanceMethods
    
    # Get potential extranal items for share.
    # 
    # Usefull for slelctors, when sharing
    def find_available_external_for_share type, options={}
      cls = eval(type.to_s.classify)
      opts = {:conditions => available_external_for_share_conditions(type)}.merge(options)
      cls.find( :all, opts )
    end

    def available_external_for_share_conditions type, options={}
      cls = eval(type.to_s.classify)
      foreign_key = self.class.table_name.singularize + '_id'
      excluded_ids = send("external_#{type.singularize}_ids".to_sym)
      if excluded_ids.size > 0
        return [ "#{foreign_key} IN (?) AND id NOT IN (?)",
                 share_pool.map{|o| o.id}, excluded_ids ]
      else
        return [ "#{foreign_key} IN (?)", share_pool.map{|o| o.id} ]
      end
    end

  end

end

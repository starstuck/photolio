module ModelExtensions::ActsAsMenuItemTarget

  def acts_as_menu_item_target
    class_eval do
      extend ClassMethods
      include InstanceMethods

      attr_writer :default_menu_label
      
      has_many :menu_items, :as => :target, :dependent => :destroy

      validates_associated :menu_items

      before_validation :prepare_default_menu_item
      after_save :save_default_menu_item
    end
  end


  module ClassMethods
  end


  module InstanceMethods

    # Accepts traeu/false and 1/0(By default form helpers use this)
    def display_in_default_menu=(value)
      if value.is_a? String
        if %w(0 no false).include? value.downcase
          value = false
        else
          value = true
        end
      else
        if value
          value = true
        else
          value = false
        end
      end
      @display_in_default_menu = value
    end

    def display_in_default_menu
      unless @display_in_default_menu.nil?
        @display_in_default_menu
      else
        begin
          if default_menu_item
            return true
          else
            return false
          end
        rescue Menu::NameError
          return false
        end
      end
    end

    def default_menu_label
      if @default_menu_label
        @default_menu_label
      else
        begin
          if default_menu_item
            return default_menu_item.label
          else
            return nil
          end
        rescue Menu::NameError; end
      end 
    end

    def default_menu_label_or_title
      result = default_menu_label
      unless result and result != ''
        result = title
      end
      result
    end

    def default_menu
      unless @default_menu_queried
        @default_menu = site.get_menu(self.class.name.tableize)
        @default_menu_queried = true
      end
      @default_menu
    end

    def default_menu_item
      unless @default_menu_item_queried
        @default_menu_item = menu_items.find(:first, 
                                             :conditions => {
                                               :menu_id => default_menu.id}
                                             )
        @default_menu_item_queried = true
      end
      if @default_menu_item_destroy_required
        return nil
      else
        @default_menu_item
      end
    end

    protected

    def prepare_default_menu_item
      if display_in_default_menu
        unless default_menu_item
          @default_menu_item = menu_items.build(:menu => default_menu,
                                                :target => self)
        end 
        menu_label_value = default_menu_label
        menu_label_value = nil if menu_label_value == ''
        default_menu_item.label = menu_label_value
      else
        if default_menu_item
          @destroy_default_menu_item = true
        end
      end
        
    end

    def save_default_menu_item
      if @destroy_default_menu_item
        default_menu_item.destroy
        @default_menu_item = nil
      end

      if default_menu_item
        default_menu_item.save!
      end
      
      if @destroy_default_menu_item or default_menu_item
        default_menu.sort_menu_items_by_label!
        @display_in_default_menu = nil
        @default_menu_label = nil
        @destroy_default_menu_item = nil
      end
    end

  end

end

class Menu < ActiveRecord::Base

  class NameError < ArgumentError; end
  

  belongs_to :site
  has_many :menu_items, :order => 'position', :dependent => :destroy

  validates_length_of :name, :maximum => 255
  validates_presence_of :name, :scope => 'site_id'

  # Make sure menu has name valid in site definition
  def validate
    menus = site.site_params.menus
    unless (menus and menus.include? name)
      errors.add('name', "'#{name}' is invalid for '#{site.name}' site")
    end
  end

  # Reorder menu items by label
  # Numeric labels are treated as numbers in sorting
  def sort_menu_items_by_label!
    items = menu_items.sort do |x, y|
      # Sort galeries like numbers if name starts from digits (2 is lower then 10)
      xn = x.label || x.target.title
      yn = y.label || y.target.title
      x_is_num = (xn.to_i != 0 or xn[0] == '0')
      y_is_num = (yn.to_i != 0 or yn[0] == '0')
      
      result = begin
                 if x_is_num and y_is_num
                   xn.to_i <=> yn.to_i
                 elsif x_is_num
                   -1
                 elsif y_is_num
                   1
                 else
                   nil
                 end
               end
      
      if result and result != 0
        result
      else
        xn <=> yn #falback to string comparision
      end
    end

    i = 0
    for item in items
      if item.position != i
        item.position = i
        item.save!
      end
      i += 1
    end
  end

  # Find previous menu item realtive to argument
  def previous_menu_item(relative_to)
    previous = nil
    for current in menu_items
      if((relative_to.is_a? MenuItem and current.id == relative_to.id) or
         (current.target_type == relative_to.class.name and 
          current.target_id == relative_to.id))
        return previous
      end
      previous = current
    end
    nil
    all_items = menu_items.map{|x| x.id}
    puts " --> Failed to find previous to: #{relative_to.id}, in #{all_items}"
  end

  # Find next menu item realtive to argument
  def next_menu_item(relative_to)
    previous = nil
    for current in menu_items
      if(previous and
         ((relative_to.is_a? MenuItem and previous.id == relative_to.id) or
          (previous.target_type == relative_to.class.name and 
           previous.target_id == relative_to.id)))
        return current
      end
      previous = current
    end
    nil
  end

end

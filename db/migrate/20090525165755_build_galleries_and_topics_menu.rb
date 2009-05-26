class BuildGalleriesAndTopicsMenu < ActiveRecord::Migration
  def self.up
    # Build menus for galleries and topics
    # Migrate gallery name to menu item label
    Gallery.reset_column_information
    for gallery in Gallery.find(:all)
      if gallery.display_in_index and gallery.site.has_menu? 'galleries'
        galleries_menu = gallery.site.get_menu('galleries')
        i = galleries_menu.menu_items.create(:target => gallery,
                                             :label => gallery.name)
        gallery.title = gallery.title
        gallery.save()
        say "Crated gallery menu: #{gallery.site.name}, #{i.label}"
      end
    end
    for topic in Topic.find(:all)                  
      if(topic.read_attribute(:display_in_menu) and 
          topic.site.has_menu? 'topics')
        topics_menu = topic.site.get_menu('topics')
        i = topics_menu.menu_items.create(:target => topic,
                                          :label => topic.title)
        say "Crated topic menu: #{topic.site.name}, #{i.label}"
      end
    end

    # Sort newly created menus
    for menu in Menu.find(:all)
      menu.sort_menu_items_by_label!
    end

    # Remove obsolete columns
    remove_column :galleries, :display_in_index
    remove_column :topics, :display_in_index
  end

  def self.down
    add_column :topics, :display_in_index, :default => true    
    add_column :galleries, :display_in_index, :default => true
  end
end

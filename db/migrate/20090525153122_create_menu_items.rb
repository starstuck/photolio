class CreateMenuItems < ActiveRecord::Migration
  def self.up
    create_table :menu_items do |t|
      t.integer :menu_id,  :null => false
      t.integer :position, :null => false, :default => 0
      t.string :label
      t.integer :target_id, :null => false
      t.string :target_type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :menu_items
  end
end

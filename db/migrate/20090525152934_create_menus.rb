class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.integer :site_id
      t.string :name

      t.timestamps
    end
    add_index :menus, :name, :unique => false
  end

  def self.down
    drop_table :menus
  end
end

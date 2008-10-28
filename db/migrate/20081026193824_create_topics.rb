class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.integer :site_id
      t.string :lang,             :limit => 2, :default => 'en'
      t.string :name,             :limit => 64
      t.string :title
      t.text :body
      t.boolean :display_in_menu, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end

class CreatePhotosSites < ActiveRecord::Migration
  def self.up
    create_table :photos_sites, :id => false do |t|
      t.integer :photo_id
      t.integer :site_id

      t.timestamps
    end
    add_index :photos_sites, :photo_id, :unique => false
    add_index :photos_sites, :site_id, :unique => false
  end

  def self.down
    drop_table :photos_sites
  end
end

class CreateGalleriesPhotos < ActiveRecord::Migration
  def self.up
    create_table :galleries_photos do |t|
      t.integer :gallery_id,  :null => false
      t.integer :photo_id
      t.integer :position,    :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :galleries_photos
  end
end

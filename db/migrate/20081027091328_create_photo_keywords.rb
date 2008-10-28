class CreatePhotoKeywords < ActiveRecord::Migration
  def self.up
    create_table :photo_keywords do |t|
      t.integer :photo_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_keywords
  end
end

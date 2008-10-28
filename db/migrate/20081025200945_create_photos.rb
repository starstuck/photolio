class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :site_id ,     :null => false
      t.string :file_name,     :null => false
      t.boolean :file_exists,  :default => true
      t.string :title
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end

class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :site_id,   :null => false
      t.string :file_name,  :null => false
      t.string :label
      t.string :mime_major, :limit => 16
      t.string :mime_minor, :limit => 32
      t.integer :size
      t.integer :image_width
      t.integer :image_height
      t.string :image_alt

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end

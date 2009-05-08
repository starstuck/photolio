class CreateAttachmentSlots < ActiveRecord::Migration
  def self.up
    create_table :attachment_slots do |t|
      t.string :name, :limit => 32, :null => false
      t.integer :having_attachment_id, :null => false
      t.string :having_attachment_type, :null => false
      t.integer :attachment_id, :null => false
      t.string :attachment_type, :null => false

      t.timestamps
    end
    add_index :attachment_slots, :name, :unique => false
    add_index :attachment_slots, :having_attachment_id, :unique => false
  end

  def self.down
    drop_table :attachment_slots
  end
end

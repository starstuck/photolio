class CreatePhotoParticipants < ActiveRecord::Migration
  def self.up
    create_table :photo_participants do |t|
      t.integer :photo_id
      t.string :role
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_participants
  end
end

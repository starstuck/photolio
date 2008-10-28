class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.integer :site_id,  :null => false
      t.string :name,      :limit => 16, :null => false
      t.string :title
      
      t.timestamps
    end
  end

  def self.down
    drop_table :galleries
  end
end

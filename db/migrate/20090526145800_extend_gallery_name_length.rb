class ExtendGalleryNameLength < ActiveRecord::Migration
  def self.up
    change_column :galleries, :name, :string, :limit => 255, :null => false
  end

  def self.down
    change_column :galleries, :name, :string, :limit => 16, :null => false
  end
end

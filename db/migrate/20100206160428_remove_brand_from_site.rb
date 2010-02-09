class RemoveBrandFromSite < ActiveRecord::Migration
  def self.up
    remove_column :sites, :brand
  end

  def self.down
    add_column :sites, :brand, :string, :limit=>16
  end
end

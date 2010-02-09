class AddParentToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :parent_id, :integer
  end

  def self.down
    remove_column :sites, :parent_id
  end
end

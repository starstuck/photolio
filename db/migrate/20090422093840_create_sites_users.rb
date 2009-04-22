class CreateSitesUsers < ActiveRecord::Migration
  def self.up
    create_table :sites_users, :id => false do |t|
      t.integer :site_id
      t.integer :user_id

      t.timestamps
    end
    add_index :sites_users, :site_id, :unique => false
    add_index :sites_users, :user_id, :unique => false
  end

  def self.down
    drop_table :sites_users
  end
end

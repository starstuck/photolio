class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.integer :user_id, :null=>false
      t.string :name, :null=>false, :limit=>32

      t.timestamps
    end
    add_index :user_roles, :user_id, :unique => false
  end

  def self.down
    drop_table :user_roles
  end
end

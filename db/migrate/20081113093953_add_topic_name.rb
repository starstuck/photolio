class AddTopicName < ActiveRecord::Migration
  def self.up
    add_column :topics, :name, :string, :null => false
    change_column :topics, :title, :string, :null => false
    
    Topic.reset_column_information
    Topic.find(:all).each do |topic|
      topic.title = topic.title.clone
      topic.save!
      say "Updated topic name: #{topic.name}"
    end
  end

  def self.down
    remove_column :topics, :name
    change_column :topics, :title, :string, :null => true
  end
end

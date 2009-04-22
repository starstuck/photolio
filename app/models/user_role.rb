class UserRole < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user
  validates_associated :user

  validates_presence_of :name
  validates_inclusion_of :name, :in => %w(users_manager)
  
end

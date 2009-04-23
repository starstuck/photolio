class UserRole < ActiveRecord::Base

  ROLES_NAMES = %w(users_manager sites_manager)

  belongs_to :user

  validates_presence_of :user
  validates_associated :user

  validates_presence_of :name
  validates_inclusion_of :name, :in => UserRole::ROLES_NAMES
  
end

require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :user_roles, :dependent => :destroy
  has_and_belongs_to_many :sites, :order => 'name', :uniq => true

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :user_roles, :sites, :must_change_password



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def label
    name != '' ? name : login
  end

  def has_role(name)
    user_roles.exists? :name => 'users_manager'
  end

  def has_site_role(site)
    sites.exists? site
  end

  def has_multisite_view
    sites.count > 1 or has_role('users_manager')
  end

  # TODO: would be nice to add few tests
  def update_roles(roles_names)
    old_roles_by_name = Hash[*user_roles.map{|r| [r.name, r]}.flatten]

    if roles_names
      for role_name in roles_names
        if old_roles_by_name.key? role_name
          old_roles_by_name.delete(role_name)
        else
          user_roles.create :name => role_name
        end
      end
    end

    # delete remaining roles
    for role in old_roles_by_name.values
      user_roles.delete(role)
    end
  end
  
end

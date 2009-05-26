class Topic < ActiveRecord::Base

  acts_as_attachment
  acts_as_named_content
  acts_as_menu_item_target

  belongs_to :site

  validates_presence_of :site
  validates_length_of :title, :maximum => 255
  validates_uniqueness_of :title, :scope => 'site_id'
  validates_length_of :body, :maximum => 30000, :allow_nil => true

end

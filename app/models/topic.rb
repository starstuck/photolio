class Topic < ActiveRecord::Base
  
  belongs_to :site

  validates_presence_of :site
  validates_length_of :lang, :maximum => 2
  validates_length_of :name, :maximum => 64
  validates_length_of :title, :maximum => 255
  validates_length_of :body, :maximum => 30000, :allow_nil => true
  validates_uniqueness_of :name, :scope => ['site_id', 'lang']

end

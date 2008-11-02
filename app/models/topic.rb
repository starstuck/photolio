require 'rdiscount'


class Topic < ActiveRecord::Base
  
  belongs_to :site

  validates_presence_of :site
  validates_length_of :title, :maximum => 255
  validates_length_of :body, :maximum => 30000, :allow_nil => true
  validates_uniqueness_of :title, :scope => ['site_id']

  # Parse Markdown markup, and build html from body
  def body_to_html
    markdown = RDiscount.new(body)
    markdown.to_html
  end

end

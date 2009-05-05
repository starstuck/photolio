class Attachment < ActiveRecord::Base

  include Common::FileModelMixin

  belongs_to :site

  validates_length_of :label, :maximum => 255, :allow_nil => true
  validates_length_of :image_alt, :maximum => 255, :allow_nil => true

  set_files_folder 'attachments'

end


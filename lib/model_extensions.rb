module ModelExtensions; end

require 'model_extensions/acts_as_attachment'
require 'model_extensions/has_attachment'
require 'model_extensions/has_file'

ActiveRecord::Base.send :extend, ModelExtensions::ActsAsAttachment
ActiveRecord::Base.send :extend, ModelExtensions::HasAttachment
ActiveRecord::Base.send :extend, ModelExtensions::HasFile

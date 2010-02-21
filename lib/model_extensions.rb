module ModelExtensions; end

require 'model_extensions/acts_as_attachment'
require 'model_extensions/acts_as_menu_item_target'
require 'model_extensions/acts_as_named_content'
require 'model_extensions/acts_as_sharable'
require 'model_extensions/has_attachment'
require 'model_extensions/has_file'
require 'model_extensions/has_shared'

ActiveRecord::Base.send :extend, ModelExtensions::ActsAsAttachment
ActiveRecord::Base.send :extend, ModelExtensions::ActsAsMenuItemTarget
ActiveRecord::Base.send :extend, ModelExtensions::ActsAsNamedContent
ActiveRecord::Base.send :extend, ModelExtensions::ActsAsSharable
ActiveRecord::Base.send :extend, ModelExtensions::HasAttachment
ActiveRecord::Base.send :extend, ModelExtensions::HasFile
ActiveRecord::Base.send :extend, ModelExtensions::HasShared

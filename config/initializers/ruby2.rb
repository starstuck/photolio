# Set of mokey patches for Ruby 2 compatibility stuff

require 'i18n/backend/active_record'
# I18n.backend = I18n::Backend::ActiveRecord.new # That one watns to look up data in database
I18n.backend = I18n::Backend::Simple.new

if Rails::VERSION::MAJOR == 2 && RUBY_VERSION >= '2.0.0'

  # yaml localization files
  module I18n
    module Backend
      module Base
        def load_file(filename)
          type = File.extname(filename).tr('.', '').downcase
          # As a fix added second argument as true to respond_to? method
          raise UnknownFileType.new(type, filename) unless respond_to?(:"load_#{type}", true)
          data = send(:"load_#{type}", filename) # TODO raise a meaningful exception if this does not yield a Hash
          data.each { |locale, d| store_translations(locale, d) }
        end
      end
    end
  end

  # Workaround for error: undefined method `insert_record' for ...
  #module ActiveRecord
  #  module Associations
  #    class AssociationProxy
  #      def send(method, *args)
  #        if proxy_respond_to?(method,true)
  #          super
  #        else
  #          load_target
  #          @target.send(method, *args)
  #        end
  #      end
  #    end
  #  end
  #end
end

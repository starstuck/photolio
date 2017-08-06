# Each site parameters witf default fallbacks

SITE_BASE_PATH="/srv/www"


module SiteParams

  class Params

    def initialize(site)
      @site = site
    end

    def self.def_param name
      name = name.to_s
      class_eval <<-EOS
        def self.#{name}(value)
          class_eval "def #{name}; return '" + value.to_s + "'; end"
        end
        def #{name}; end
      EOS
    end

    def self.def_attachment_slot(container, name, options={})
      definition = AttachmentSlot::Definition.new(name.to_s, options)
      attachment_slots(container)[definition.name] = definition
    end

    def self.attachment_slots(container)
      if container.is_a? String
        container_name = container
      elsif container.is_a? Class
        container_name = container.to_s
      elsif container.is_a? ActiveRecord::Base
        container_name = container.class.to_s
      else
        raise ArgumentError.new("Wrong containter: #{container_name}")
      end
      unless %w(Gallery Site).include? container_name
        raise ArgumentError.new("Wrong containter: #{container_name}")
      end
      @attachment_slots ||= {}
      @attachment_slots[container_name] ||= {}
    end

    def attachment_slots(container)
      super_slots = self.class.superclass.attachment_slots(container)
      super_slots.merge self.class.attachment_slots(container)
    end

    # Hash with gallery attachement slots
    def gallery_attachment_slots
      attachment_slots('Gallery')
    end

    def site_attachment_slots
      attachment_slots('Site')
    end

    # Maximum photo size stored on disk. On upload all larger photos will be
    # resized to this size before storing.
    # Format: <width>x<height>. Only one of width, height must be provided.
    def_param :photo_store_size

    # Location, where to publish site
    def_param :publish_location

    # Published site url prefix.
    def_param :published_url_prefix

    # Location, where to publish site assets
    def_param :publish_assets_location

    # Published site assets files url prefix
    def_param :published_assets_url_prefix

    # Site menus 'galleries' and 'topics' are special kind of menues, which are
    # managed directly for gallery and topic page
    def_param :menus

    # Theme - controller to use for rendering site. If not provide used name based
    # on site name
    # Use theme controllers and views relative path
    def_param :theme

  end


  class DefaultParams < Params

    def publish_assets_location
      publish_location
    end

    def published_assets_url_prefix
      published_url_prefix
    end

  end

  class PolinostudioParams < DefaultParams
    photo_store_size 'x400'
    publish_location "#{SITE_BASE_PATH}/polinostudio"
    published_url_prefix 'http://old.polinostudio.com'
    menus ['galleries', 'topics']
    theme 'polinostudio'
  end

  def self.for_site(site)
    if site.name == 'polinostudio'
      params_factory = PolinostudioParams
    else
      params_factory = DefaultParams
    end
    return params_factory.new(site)
  end

end

require 'test_helper'

class DummyDefaultParams < SiteParams::Params
end

class DummyParams < DummyDefaultParams
end

class SiteParamsTest < ActiveSupport::TestCase

  def setup 
    @site = sites(:polinostudio)
    @site_params = DummyParams.new(@site)
  end

  def test_string_paramters
    DummyDefaultParams.class_eval do
      photo_store_size 'x350'
      published_url_prefix 'dummy'
    end

    DummyParams.class_eval do
      photo_store_size 'x420'
    end

    assert_equal 'x420', @site_params.photo_store_size
    assert_equal 'dummy', @site_params.published_url_prefix
    assert_equal nil, @site_params.publish_location
  end

  def test_attachment_slots_definition
    DummyDefaultParams.class_eval do
      def_attachment_slot Gallery, :banner
    end

    DummyParams.class_eval do
      def_attachment_slot 'Gallery', 'icon', :valid_types => [Photo, Asset]
    end
    
    assert_raise ArgumentError do
      DummyParams.class_eval do
        def_attachment_slot 'WrongClass', 'wrong'
      end
    end

    assert_equal ['banner', 'icon'], @site_params.attachment_slots(Gallery).keys
    assert_equal ['banner', 'icon'], @site_params.gallery_attachment_slots.keys
  end

end

require 'test_helper'


class DummySite
  attr_reader :name
  def initialize(name)
    @name = name
  end
end


class DummyController
  attr_reader :gallery
  def initialize(site)
    @site = site
  end
end


class SiteIntrospectorTest < Test::Unit::TestCase

  def test_controller_info
    site = DummySite.new('polinostudio')
    info = SiteIntrospector.introspect(site)

    assert_equal 'polinostudio', info.theme_name
    
    controllers_info = info.controllers_infos

    assert_equal ['gallery', "photo", "site", "topic"], controllers_info.map{|x| x.name}.sort
    
    cinfo = controllers_info.reject{|x| x.name != 'gallery'}[0]

    assert_equal 'site/polinostudio/gallery', cinfo.path
    assert_equal [:show], cinfo.pages_keys
    assert_equal true, cinfo.page_info(:show).in_sitemap?
    
    assert_equal [:gallery], cinfo.context_names
  end

  def test_setup_controller_context
    site = Site.find_by_name('polinostudio')
    controller = DummyController.new(site)

    cinfo = SiteIntrospector::ControllerInfo.instance(Site::Polinostudio::GalleryController)
    cinfo.setup_context(controller, {:controller_context => '1'})
    
    assert_equal 'First gallery', controller.gallery.title
  end

  def test_theme_public_paths
    site = Site.find_by_name('polinogroup')
    info = SiteIntrospector.introspect(site)
    assert_equal %w(polinogroup/main polinogroup/common), info.theme_public_paths
  end

end

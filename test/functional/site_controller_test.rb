require 'test_helper'

class SiteControllerTest < ActionController::TestCase

  def test_should_show_google_sitemap
    get( 'sitemap',
         { :site_name => 'studio',
           :format => 'xml',
           :published => true
         } )
    assert_response :success
  end

  def test_raw_sitemap
    sitemap = SiteController.raw_sitemap(sites(:studio))
    assert_equal 7, sitemap.size

    assert_equal '/gallery', sitemap[0]['loc'][:controller]
    assert_equal '1', sitemap[0]['loc'][:gallery_name]
    assert_equal DateTime.new(2008, 1, 1), sitemap[0]['lastmod']
  end
  
  def test_update_gallery_timestamp
    galleries(:one).mark_as_new = true
    galleries(:one).save()
    
    sitemap = SiteController.raw_sitemap(sites(:studio))

    assert_equal DateTime.now.strftime('%F'), sitemap[0]['lastmod'].strftime('%F')
    assert_equal DateTime.now.strftime('%F'), sitemap[1]['lastmod'].strftime('%F')
  end

  def test_update_photo_timestamp 
    photos(:one).updated_at = DateTime.now
    photos(:one).save()

    sitemap = SiteController.raw_sitemap(sites(:studio))

    sitemap = SiteController.raw_sitemap(sites(:studio))
    assert_equal DateTime.now.strftime('%F'), sitemap[0]['lastmod'].strftime('%F')
    assert_equal DateTime.new(2008, 1, 1), sitemap[1]['lastmod']
  end

  # TODO: more verbose changes on nested elements
end

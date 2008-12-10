require 'test_helper'

class SiteControllerTest < ActionController::TestCase

  def test_should_show_google_sitemap
    get 'sitemap', :format => 'xml', :site_name => 'studio'
    assert_response :success
  end

  def test_raw_sitemap
    sitemap = SiteController.raw_sitemap(sites(:studio))
    assert_equal 7, sitemap.size
  end
end

require 'test_helper'

class Site::SiteControllerTest < ActionController::TestCase

  def test_should_show_google_sitemap
    get( :sitemap,
         :site_name => sites(:polinostudio).name,
         :format => 'xml' )
    assert_response :success
  end

  def test_site_pages
    sitemap = Site::SiteController.site_pages(sites(:polinostudio), true)
    assert_equal 8, sitemap.size #sitemap.map{|x| x[:loc][:controller]}.join(", \n")

    assert_equal 'site/polinostudio/photo', sitemap[0][:loc][:controller]
    assert_equal 1, sitemap[0][:loc][:controller_context]
    # Currently modification time is not supported
    #assert_equal DateTime.new(2008, 1, 1), sitemap[0][:lastmod]
  end
  
  # Currently modification time is not supported
  #def test_update_gallery_timestamp
  #  galleries(:one).mark_as_new = true
  #  galleries(:one).save()
  #  
  #  sitemap = Site::SiteController.raw_sitemap(sites(:polinostudio))
  #
  #  assert_equal DateTime.now.strftime('%F'), sitemap[0][:lastmod].strftime('%F')
  #  assert_equal DateTime.now.strftime('%F'), sitemap[1][:lastmod].strftime('%F')
  #end
  #
  #def test_update_photo_timestamp 
  #  photos(:one).updated_at = DateTime.now
  #  photos(:one).save()
  #
  #  sitemap = Site::SiteController.raw_sitemap(sites(:polinostudio))
  #
  #  sitemap = Site::SiteController.raw_sitemap(sites(:polinostudio))
  #  assert_equal DateTime.now.strftime('%F'), sitemap[0][:lastmod].strftime('%F')
  #  assert_equal DateTime.new(2008, 1, 1), sitemap[1][:lastmod]
  #end

end

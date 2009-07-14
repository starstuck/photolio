require 'test_helper'

class Site::SiteController; def rescue_action(e) raise e end; end
class Site::GalleryController; def rescue_action(e) raise e end; end

# Build tests for all sites that are dispatched to sites controllers
class Site::PitchouguinaControllerExtensionsTest < ActionController::TestCase

  def setup 
    @site = sites(:pitchouguina)
  end

  test 'show site' do
    @controller = Site::SiteController.new
    get( 'dispatch',
         :method_name => 'show',
         :site_name => @site.name
         )
    assert_response 200
  end

  test 'show galleries' do
    @controller = Site::SiteController.new
    get( 'dispatch',
         :method_name => 'galleries',
         :site_name => @site.name
         )
    assert_response 200
  end

  test 'show gallery' do
    @controller = Site::GalleryController.new
    @gallery = galleries(:cardigans)
    get( 'dispatch',
         :method_name => 'show',
         :site_name => @site.name,
         :gallery_name => @gallery.name
         )
    assert_response :success
  end

  test 'show topic' do
    @controller = Site::TopicController.new
    @topic = @site.topics[0]
    get( 'dispatch',
         :method_name => 'show',
         :site_name => @site.name,
         :topic_name => @topic.name
         )
    assert_response :success
  end

end

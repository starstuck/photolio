require 'test_helper'

# Build tests for all sites that are dispatched to sites controllers
class Site::PolinostudioControllerExtensionsTest < ActionController::TestCase

  def setup 
    @site = sites(:polinostudio)
  end

  test 'show site' do
    @controller = Site::SiteController.new
    get( 'dispatch',
         :method_name => 'show',
         :site_name => @site.name
         )
    assert_response 307
  end

  test 'show gallery' do
    @controller = Site::GalleryController.new
    @gallery = @site.galleries[0]
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

  test 'show photo' do
    @controller = Site::PhotoController.new
    @photo = @site.photos[0]
    get( 'dispatch',
         :method_name => 'show',
         :site_name => @site.name,
         :photo_id => @photo.id
         )
    assert_response :success
  end


end

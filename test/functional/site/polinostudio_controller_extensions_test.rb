require 'test_helper'

# Build tests for all sites that are dispatched to sites controllers
class Site::PolinostudioControllerExtensionsTest < ActionController::TestCase

  def setup 
    @site = sites(:polinostudio)
  end

  test 'show site' do
    @controller = Site::Polinostudio::SiteController.new
    get( 'show',
         :site_name => @site.name
         )
    assert_response 307
  end

  test 'show gallery' do
    @controller = Site::Polinostudio::GalleryController.new
    @gallery = @site.galleries[0]
    get( 'show',
         :site_name => @site.name,
         :controller_context => @gallery.name
         )
    assert_response :success
  end

  test 'show topic' do
    @controller = Site::Polinostudio::TopicController.new
    @topic = @site.topics[0]
    get( 'show',
         :site_name => @site.name,
         :controller_context => @topic.name
         )
    assert_response :success
  end

  test 'show photo' do
    @controller = Site::Polinostudio::PhotoController.new
    @photo = @site.photos[0]
    get( 'show',
         :site_name => @site.name,
         :controller_context => @photo.id
         )
    assert_response :success
  end


end

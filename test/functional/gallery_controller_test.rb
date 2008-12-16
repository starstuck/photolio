require 'test_helper'

class GalleryControllerTest < ActionController::TestCase

  def test_should_show
    get( :show, 
         { :site_name => 'studio',
           :gallery_name => galleries(:one).name,
           :format => 'html',
           :published => true
         })
    assert_response :success
  end
end

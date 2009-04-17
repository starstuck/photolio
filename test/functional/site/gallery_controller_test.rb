require 'test_helper'

class Site::GalleryControllerTest < ActionController::TestCase

  def test_should_show_polinostudio
    get( :show, 
         { :site_name => sites(:polinostudio).name,
           :gallery_name => galleries(:one).name,
           :format => 'html',
         })
    assert_response :success
  end
end

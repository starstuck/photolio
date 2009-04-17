require 'test_helper'

class Site::PhotoControllerTest < ActionController::TestCase

  def test_should_show_polinostudio
    get( :show,
         { :site_name => sites(:polinostudio).name,
           :photo_id => photos(:one).id,
           :format => 'html',
         } )
    assert_response :success
  end
end

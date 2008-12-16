require 'test_helper'

class PhotoControllerTest < ActionController::TestCase

  def test_should_show
    get( :show,
         { :site_name => sites(:studio).name,
           :photo_id => photos(:one).id,
           :format => 'html',
           :published => true
         } )
    assert_response :success
  end
end

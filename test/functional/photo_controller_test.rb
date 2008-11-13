require 'test_helper'

class PhotoControllerTest < ActionController::TestCase

  def test_should_show
    get :show, :site_name => sites(:studio).name, :id => photos(:one).id, :format => 'html'
    assert_response :success
  end
end

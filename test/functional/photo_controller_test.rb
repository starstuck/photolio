require 'test_helper'

class PhotoControllerTest < ActionController::TestCase

  def test_should_show
    get :show, :site_name => sites(:studio).name, :gallery_name => galleries(:one).name, :id => photos(:one).id
    assert_response :success
  end
end

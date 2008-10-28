require 'test_helper'

class GalleryControllerTest < ActionController::TestCase

  def test_should_show
    get :show, :site_name => 'studio', :name => galleries(:one).id
    assert_response :success
  end
end

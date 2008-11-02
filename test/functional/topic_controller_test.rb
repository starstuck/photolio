require 'test_helper'

class TopicControllerTest < ActionController::TestCase

  def test_should_show
    get :show, :site_name => 'studio', :id => topics(:one).id
    assert_response :success
  end
end

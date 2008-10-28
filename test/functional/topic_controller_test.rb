require 'test_helper'

class TopicControllerTest < ActionController::TestCase

  def test_should_show
    get :show, :site_name => 'studio', :name => topics(:one).name
    assert_response :success
  end
end

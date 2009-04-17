require 'test_helper'

class Site::TopicControllerTest < ActionController::TestCase

  def test_should_show
    get( :show, 
         { :site_name => 'polinostudio',
           :topic_name => topics(:one).name,
           :format => 'html',
         } )
    assert_response :success
  end
end

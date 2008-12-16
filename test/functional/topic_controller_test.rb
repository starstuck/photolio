require 'test_helper'

class TopicControllerTest < ActionController::TestCase

  def test_should_show
    get( :show, 
         { :site_name => 'studio',
           :topic_name => topics(:one).name,
           :format => 'html',
           :published => true
         } )
    assert_response :success
  end
end

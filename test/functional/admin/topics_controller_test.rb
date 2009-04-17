require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :site_id => sites(:polinostudio).id
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  def test_should_get_new
    get :new, :site_id => sites(:polinostudio).id
    assert_response :success
  end

  def test_should_create_topic
    assert_difference('Topic.count') do
      post :create, :site_id => sites(:polinostudio), :topic => { :title => 'New topic' }
    end
    assert_redirected_to admin_site_topic_path(assigns(:site), assigns(:topic))
  end

  def test_should_show_topic
    get :show, :site_id => sites(:polinostudio), :id => topics(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => sites(:polinostudio), :id => topics(:one).id
    assert_response :success
  end

  def test_should_update_topic
    put :update, :site_id => sites(:polinostudio), :id => topics(:one).id, :topic => { :title => 'Updated title' }
    assert_redirected_to admin_site_topic_path(assigns(:site), assigns(:topic))
  end

  def test_should_destroy_topic
    assert_difference('Topic.count', -1) do
      delete :destroy, :site_id => sites(:polinostudio), :id => topics(:one).id
    end

    assert_redirected_to admin_site_topics_path
  end
end

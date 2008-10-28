require 'test_helper'

class Admin::PhotoKeywordsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :site_id => sites(:studio), :photo_id => photos(:one)
    assert_response :success
    assert_not_nil assigns(:photo_keywords)
  end

  def test_should_get_new
    get :new, :site_id => sites(:studio), :photo_id => photos(:one)
    assert_response :success
  end

  def test_should_create_photo_keyword
    assert_difference('PhotoKeyword.count') do
      post :create, :site_id => sites(:studio), :photo_id => photos(:one), :photo_keyword => { :name => 'some kw' }
    end

    assert_redirected_to admin_site_photo_keywords_path(assigns(:site), assigns(:photo))
  end

  def test_should_show_photo_keyword
    get :show, :site_id => sites(:studio), :photo_id => photos(:one), :id => photos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => sites(:studio), :photo_id => photos(:one), :id => photos(:one).id
    assert_response :success
  end

  def test_should_update_photo_keyword
    put :update, :site_id => sites(:studio), :photo_id => photos(:one), :id => photos(:one).id, :photo_keyword => { :name => 'new_name'}
    assert_redirected_to admin_site_photo_keywords_path(assigns(:site), assigns(:photo))
  end

  def test_should_destroy_photo_keyword
    assert_difference('PhotoKeyword.count', -1) do
      delete :destroy, :site_id => sites(:studio), :photo_id => photos(:one), :id => photos(:one).id
    end

    assert_redirected_to admin_site_photo_keywords_path
  end
end

require 'test_helper'

class Admin::PhotosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :site_id => 1
    assert_response :success
    assert_not_nil assigns(:photos)
  end

  def test_should_get_new
    get :new, :site_id => 1
    assert_response :success
  end

  def test_should_create_photo
    assert_difference('Photo.count') do
      post :create, :site_id => 1, :photo => { :file_name => 'some_file.jpg' }
    end

    assert_redirected_to admin_site_photos_path(assigns(:site))
  end

  def test_should_show_photo
    get :show, :site_id => 1, :id => photos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => 1, :id => photos(:one).id
    assert_response :success
  end

  def test_should_update_photo
    put :update, :site_id => 1, :id => photos(:one).id, :photo => { :file_name => 'new_name'}
    assert_redirected_to admin_site_photo_path(assigns(:site), assigns(:photo))
  end

  def test_should_destroy_photo
    assert_difference('Photo.count', -1) do
      delete :destroy, :site_id => 1, :id => photos(:one).id
    end

    assert_redirected_to admin_site_photos_path
  end
end

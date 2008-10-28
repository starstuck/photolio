require 'test_helper'

class Admin::SitesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:sites)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_site
    assert_difference('Site.count') do
      post :create, :site => { :name => 'New site' }
    end

    assert_redirected_to admin_site_path(assigns(:site))
  end

  def test_should_show_site
    get :show, :id => sites(:studio).id
    assert_response :success
    assert_not_nil assigns(:site)
  end

  def test_should_get_edit
    get :edit, :id => sites(:studio).id
    assert_response :success
  end

  def test_should_update_site
    put :update, :id => sites(:studio).id, :site => { :name => 'studio2' }
    assert_redirected_to admin_site_path(assigns(:site))
    assert_equal 'studio2', assigns['site'].name
  end

  def test_should_destroy_site
    assert_difference('Site.count', -1) do
      delete :destroy, :id => sites(:studio).id
    end

    assert_redirected_to admin_sites_path
  end
end

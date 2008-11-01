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

  def test_get_layout
    get :layout, :id => sites(:studio).id
    assert_response :success
    assert_not_nil assigns['galleries']
  end

  def test_get_layout_gallery_photos_partial
    get(:layout_gallery_photos_partial, 
        :id => sites(:studio).id, 
        :gallery_id => galleries(:one).id)
    assert_response :success
    assert_not_nil assigns['gallery']
  end

  def test_get_layout_unassigned_photos_partial
    get(:layout_unassigned_photos_partial, :id => sites(:studio).id)
    assert_response :success
    assert_not_nil assigns['unassigned_photos']
  end

  def test_layout_add_gallery_photo
    post(:layout_add_gallery_photo, 
         :id => sites(:studio).id,
         :gallery_id => galleries(:one).id,
         :photo_id => photos(:four).id,
         :photo_position => '1')
    assert_response :success
    assert_template '_layout_gallery_photos'
    assert_equal ['One', 'Four', 'Two', 'Three'], assigns['gallery'].photos.map{|p| p.title}
  end

  def test_layout_remove_gallery_photo
    post(:layout_remove_gallery_photo, 
         :id => sites(:studio).id,
         :photo_id => photos(:two).id)
    assert_response :success
    assert_template '_layout_unassigned_photos'
    assert_equal ['Two', 'Four'], assigns['unassigned_photos'].map{|p| p.title}
  end

end

require 'test_helper'

class Admin::GalleriesControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  def setup
    super
    login_as users(:quentin)
  end

  def test_should_get_index
    get :index, :site_id => sites(:polinostudio).id
    assert_response :success
    assert_not_nil assigns(:galleries)
  end

  def test_should_get_new
    get :new, :site_id => sites(:polinostudio).id 
    assert_response :success
  end

  def test_should_create_gallery
    assert_difference('Gallery.count') do
      post :create, :site_id => 1, :gallery => {:name => '3'}
    end

    assert_redirected_to admin_site_galleries_path(assigns(:site))
  end

  def test_should_show_gallery
    get :show, :site_id => sites(:polinostudio).id, :id => galleries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => sites(:polinostudio).id, :id => galleries(:one).id
    assert_response :success
  end

  def test_should_update_gallery
    put(:update, 
        :site_id => sites(:pitchouguina), 
        :id => galleries(:love_stories).id, 
        :gallery => { 
          :name => 'NY Love stories',
          :attachment_slots => {
            :banner => {
              :attachment_id => assets(:love_stories_banner).id,
              :attachment_type => 'Asset' },
            :menu_label => {
              :attachment_id => '',
              :attachment_type => 'Asset'
            }}
        })
    assert_redirected_to admin_site_galleries_path(assigns(:site))
  end

  def test_should_destroy_gallery
    assert_difference('Gallery.count', -1) do
      delete :destroy, :site_id => sites(:polinostudio), :id => galleries(:one).id
    end

    assert_redirected_to admin_site_galleries_path
  end
end

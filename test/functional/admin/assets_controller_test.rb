require 'test_helper'

class Admin::AssetsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  def setup
    super
    login_as users(:quentin)
  end

  def test_should_get_index
    get :index, :site_id => sites(:pitchouguina).id
    assert_response :success
    assert_not_nil assigns(:assets)
  end

  def test_should_get_new
    get :new, :site_id => sites(:pitchouguina).id
    assert_response :success
  end

  def test_should_create_asset
    file_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures/files/x.png")
    @temp_dir = File.join(RAILS_ROOT, 'tmp', "test_#{rand.to_s[2..-1]}")
    FileUtils.mkdir_p(@temp_dir)
    
    Asset.instance_variable_set :@public_path, @temp_dir
    assert_difference('Asset.count') do
      f = File.open(file_path, "r")
      post :create, :site_id => sites(:pitchouguina).id, :asset => { :file => f }
      f.close
    end
    Asset.instance_variable_set :@public_path, nil

    created_path = File.expand_path(@temp_dir + "/pitchouguina/files/assets/x.png")
    assert((File.exists? created_path), "Does not exists: " + created_path)
    assert_redirected_to admin_site_asset_path(assigns(:site), assigns['asset'])

    FileUtils.rm_rf @temp_dir
  end

  def test_should_show_asset
    get :show, :site_id => assets(:love_stories_banner).site_id, :id => assets(:love_stories_banner).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => assets(:love_stories_banner).site_id, :id => assets(:love_stories_banner).id
    assert_response :success
  end

  def test_should_update_asset
    put :update, :site_id => assets(:love_stories_banner).site_id, :id => assets(:love_stories_banner).id, :asset => { :label => 'new_label'}
    assert_redirected_to admin_site_asset_path(assigns(:site), assigns(:asset))
  end

  def test_should_destroy_asset
    assert_difference('Asset.count', -1) do
      delete :destroy, :site_id => assets(:love_stories_banner).site_id, :id => assets(:love_stories_banner).id
    end
    assert_redirected_to admin_site_assets_path
  end
end

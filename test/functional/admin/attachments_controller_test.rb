require 'test_helper'

class Admin::AttachmentsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  def setup
    super
    login_as users(:aaron)
  end

  def test_should_get_index
    get :index, :site_id => 1
    assert_response :success
    assert_not_nil assigns(:attachments)
  end

  def test_should_get_new
    get :new, :site_id => 1
    assert_response :success
  end

  def test_should_create_attachment
    file_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures/files/x.png")
    @temp_dir = File.join(RAILS_ROOT, 'tmp', "test_#{rand.to_s[2..-1]}")
    FileUtils.mkdir_p(@temp_dir)
    
    Attachment.instance_variable_set :@public_root, @temp_dir
    assert_difference('Attachment.count') do
      f = File.open(file_path, "r")
      post :create, :site_id => 1, :attachment => { :file => f }
      f.close
    end
    Attachment.instance_variable_set :@public_root, nil

    created_path = File.expand_path(@temp_dir + "/polinostudio/attachments/x.png")
    assert((File.exists? created_path), "Does not exists: " + created_path)
    assert_redirected_to admin_site_attachment_path(assigns(:site), assigns['attachment'])

    FileUtils.rm_rf @temp_dir
  end

  def test_should_show_attachment
    get :show, :site_id => 1, :id => attachments(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => 1, :id => attachments(:one).id
    assert_response :success
  end

  def test_should_update_attachment
    put :update, :site_id => 1, :id => attachments(:one).id, :attachment => { :label => 'new_label'}
    assert_redirected_to admin_site_attachment_path(assigns(:site), assigns(:attachment))
  end

  def test_should_destroy_attachment
    assert_difference('Attachment.count', -1) do
      delete :destroy, :site_id => 1, :id => attachments(:one).id
    end
    assert_redirected_to admin_site_attachments_path
  end
end

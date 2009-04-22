require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/users_controller'

# Re-raise errors caught by the controller.
class Admin::UsersController; def rescue_action(e) raise e end; end


class Admin::UsersControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users, :user_roles

  def test_should_list_users
    login_as users(:quentin)
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  def test_should_show
    login_as users(:quentin)
    get :show, :id => users(:quentin).id
    assert_response :success
  end

  def test_should_show_owner
    login_as users(:aaron)
    get :show, :id => users(:aaron).id
    assert_response :success
  end

  def test_should_deny_show_not_owner
    login_as users(:aaron)
    get :show, :id => users(:quentin).id
    assert_response :redirect
    assert_equal 'You have insufficient permissions to access requested page.', flash[:notice]
  end

  def test_should_create_new_user
    login_as users(:quentin)
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_get_new
    login_as users(:quentin)
    get :new
    assert_response :success
    assert_template 'admin/users/new'
  end

  def test_should_get_edit
    login_as users(:quentin)
    get :edit, :id => users(:aaron).id
    assert_response :success
    assert_template 'admin/users/edit'
  end

  def test_should_get_change_password
    login_as users(:quentin)
    get :change_password, :id => users(:quentin).id
    assert_response :success
    assert_template 'admin/users/change_password'
  end

  def test_should_reset_password
    login_as users(:quentin)
    old_passwd = users(:aaron).crypted_password
    get :reset_password, :id => users(:aaron).id
    assert_not_equal old_passwd, assigns(:user).crypted_password
    assert_equal true, assigns(:user).must_change_password
    assert_response :redirect
    assert_match 'User password has been reseted', flash[:notice]
  end

  def test_should_deny_create_new_user
    login_as users(:aaron)
    assert_no_difference 'User.count' do
      create_user
      assert_response :redirect
      assert_equal 'You have insufficient permissions to access requested page.', flash[:notice]
    end
  end

  def test_should_require_login_on_new_user
    login_as users(:quentin)
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_email_on_new_user
    login_as users(:quentin)
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_update
    login_as users(:quentin)

    post(:update, 
         :id => users(:quentin).id, 
         :user => {
           :password => 'quire69'
         })

    assert assigns(:user).errors.on(:password_confirmation)
    assert_response :success
  end  

  def test_should_update_passowrd
    login_as users(:quentin)
    old_passwd = users(:quentin).crypted_password

    post(:update, 
         :id => users(:quentin).id, 
         :user => {
           :password => 'quire69', 
           :password_confirmation => 'quire69',
           :must_change_password => false
         })

    assert_response :redirect
    assert_not_equal old_passwd, assigns(:user).crypted_password
  end

  def test_should_update_data
    login_as users(:quentin)

    post(:update, 
         :id => users(:aaron).id,
         :user_roles => ['users_manager'],
         :user_sites => [sites(:polinostudio).id],
         :user => {
           :email => 'newaaron@example.com'
         })

    assert_response :redirect
    assert_equal 'newaaron@example.com', assigns(:user).email
    assert_equal ["users_manager"], assigns(:user).user_roles.find(:all).collect{|r| r.name}
    assert_equal [1], assigns(:user).site_ids
  end

  def test_should_destroy_user
    login_as users(:quentin)
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:aaron).id
    end
    assert_redirected_to admin_users_path
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end

require 'test_helper'

class Admin::SitesControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  def setup
    super
    login_as users(:aaron)
  end   

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_equal Site.count, assigns(:sites).size
  end

  def test_should_get_full_index
    login_as users(:quentin)
    get :index
    assert_response :success
    assert_equal Site.count, assigns(:sites).size
  end

  def test_should_deny_get_new
    get :new
    assert_response :redirect
    assert_match  'insufficient permissions', flash[:notice]
  end

  def test_should_get_new
    login_as users(:quentin)
    get :new
    assert_response :success
  end


  def test_should_create_site
    login_as users(:quentin)
    assert_difference('Site.count') do
      post :create, :site => { :name => 'New site' }
    end
    assert_redirected_to admin_sites_path
  end

  def test_should_show_site
    get :show, :id => sites(:polinostudio).id
    assert_response :success
    assert_not_nil assigns(:site)
  end

  def test_should_deny_show_site
    get :show, :id => sites(:pitchouguina).id
    assert_response :redirect
    assert_match 'insufficient permissions', flash[:notice]
  end

  def test_should_get_edit
    get :edit, :id => sites(:polinostudio).id
    assert_response :success
  end

  def test_should_update_site
    put :update, :id => sites(:polinostudio).id, :site => { :name => 'studio2' }
    assert_redirected_to admin_site_path(assigns(:site))
    assert_equal 'studio2', assigns['site'].name
  end

  def test_should_destroy_site
    assert_difference('Site.count', -1) do
      delete :destroy, :id => sites(:polinostudio).id
    end

    assert_redirected_to admin_sites_path
  end

  def test_get_layout
    get :layout, :id => sites(:polinostudio).id
    assert_response :success
    assert_not_nil assigns['galleries']
  end

  def test_layout_add_gallery_photo
    post(:layout_add_gallery_photo, 
         :id => sites(:polinostudio).id,
         :gallery_id => galleries(:one).id,
         :photo_id => "unassigned_#{photos(:four).id}",
         :position => '1')
    assert_response :success
    assert_template '_layout_gallery_photos'
    assert_equal ['One', 'Four', 'Two', 'Three'], assigns['gallery'].photos.map{|p| p.title}
  end

  def test_layout_remove_gallery_photo
    post(:layout_remove_gallery_photo, 
         :id => sites(:polinostudio).id,
         :photo_id => "#{galleries(:one).id}_#{photos(:two).id}")
    assert_response :success
    assert_template '_layout_unassigned_photos'
    assert_equal ['Two', 'Four'], assigns['site'].unassigned_photos.map{|p| p.title}
  end

  def test_layout_add_gallery_separator
    assert_equal 4, galleries(:one).gallery_items.size
    post(:layout_add_gallery_separator, 
         :id => sites(:polinostudio).id,
         :gallery_id => galleries(:one).id,
         :position => '3')
    assert_response :success
    assert_template '_layout_gallery_photos'
    assert_equal ['One', 'Two', 'Three'], assigns['gallery'].photos.map{|p| p.title}
    assert_equal 5, assigns['gallery'].gallery_items.size
    assert_equal 'GallerySeparator', assigns['gallery'].gallery_items[3].type
  end

  def test_layout_remove_gallery_separator
    assert_difference('GalleryItem.count', -1) do
      post(:layout_remove_gallery_separator, 
           :id => sites(:polinostudio).id,
           :gallery_id => galleries(:one).id,
           :separator_id => '2')
    end
    assert_response :success
    assert_template '_layout_gallery_photos'
  end
end


class Admin::PublishSiteTest < ActionController::TestCase
  include AuthenticatedTestHelper
  
  tests Admin::SitesController

  def set_polinostudio_publish_location(location)
    SiteParams::PolinostudioParams.class_eval do
      publish_location location
    end
  end

  # patch publisher to skip assets publication for speed
  def setup_publisher_patch
    eval <<-EOS
      class Publisher::AbstractPublisher
        alias_method :copy_assets_folder_without_patch_test, :copy_assets_folder
        def copy_assets_folder
        end
      end
    EOS
  end

  def teardown_publisher_patch
    eval <<-EOS
      class Publisher::AbstractPublisher
        alias_method :copy_assets_folder, :copy_assets_folder_without_patch_test
      end
    EOS
  end

  def setup
    # Setup temporary public directory
    @old_public_path = sites(:polinostudio).site_params.publish_location
    @temp_dir = File.join(RAILS_ROOT, 'tmp', "test_#{rand.to_s[2..-1]}")
    FileUtils.mkdir_p(@temp_dir)
    set_polinostudio_publish_location(@temp_dir)
    setup_publisher_patch
    login_as users(:aaron)
  end
  
  def teardown
    # Cleanup temporary public directory
    set_polinostudio_publish_location(@old_public_path)
    teardown_publisher_patch
    FileUtils.rm_rf [@temp_dir]
  end  

  def test_publish_with_update
    get :publish, :id => sites(:polinostudio).id

    assert_redirected_to :action => 'show'
    assert_match /2 galleries/, flash[:notice]
    assert_match /2 topics/, flash[:notice]
    assert_match /3 photos/, flash[:notice]
    assert_match /0 other/, flash[:notice]

    # Do not assert modification time, as it is currently not properly calculated
    #assert_equal DateTime.new(2008, 1, 1), File.mtime( File.join(@temp_dir, 'gallery', '1.html') )
  end

end

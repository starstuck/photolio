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
         :position => '1')
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

  def test_layout_add_gallery_separator
    assert_equal 4, galleries(:one).gallery_items.size
    post(:layout_add_gallery_separator, 
         :id => sites(:studio).id,
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
           :id => sites(:studio).id,
           :gallery_id => galleries(:one).id,
           :separator_id => '2')
    end
    assert_response :success
    assert_template '_layout_gallery_photos'
  end
end


class Admin::PublishSiteTest < ActionController::TestCase
  
  tests Admin::SitesController
  
  def setup
    # setup temporary public directory
    @old_public_path = Rails.public_path
    @temp_dir = File.join(RAILS_ROOT, 'tmp', "test_#{rand.to_s[2..-1]}")
    FileUtils.mkdir_p(@temp_dir)
    Rails.public_path = @temp_dir    
  end

  def teardown
    # Cleanup temporary public directory
    Rails.public_path = @old_public_path
    FileUtils.rm_rf [@temp_dir]
  end

  def test_publish
    # TODO: add timestamping tests

    get :publish, :id => sites(:studio).id
    assert_redirected_to :action => 'show'
    assert_match /2 galleries/, flash[:notice]
    assert_match /2 topics/, flash[:notice]
    assert_match /3 photos/, flash[:notice]

    assert_equal DateTime.new(2008, 1, 1), File.mtime( File.join(@temp_dir, 'gallery', '1.html') )
  end

  def should_test_cleanup
    #TODO: fill
  end

end

require 'test_helper'

class HasSharedTest < ActiveSupport::TestCase

  def setup
    @site = sites(:polinogroup)
  end 

  def test_get_owned_items
    assert_equal [photos(:p4), photos(:p5)], @site.owned_photos
  end

  def test_get_shared_only_items
    assert_equal [photos(:p2), photos(:p3)], @site.external_photos
  end

  def test_get_owned_and_shared_items
    assert_equal [photos(:p2), photos(:p3), photos(:p4), photos(:p5)], @site.photos
  end

  def test_get_items_by_id
    assert_equal photos(:p2), @site.photos.find( photos(:p2).id )
  end

  def test_sites_share_pool
    assert_equal( [sites(:polinobeauty), sites(:polinofashion)], 
                  sites(:polinogroup).share_pool )
    assert_equal( [sites(:polinogroup), sites(:polinobeauty)], 
                  sites(:polinofashion).share_pool )
    assert_equal( [], sites(:polinostudio).share_pool )
  end

  def test_find_available_external_for_share
    assert_equal [photos(:p1), photos(:p6)], @site.find_available_external_photos(:order => 'file_name')
    # require test for sites, that does not have shared items
    assert_equal [photos(:p1), photos(:p2), photos(:p4), photos(:p5)], sites(:polinofashion).find_available_external_photos(:order => 'file_name')
  end

end

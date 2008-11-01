require 'test_helper'

class GalleryTest < ActiveSupport::TestCase

  def test_add_photo
    gallery = galleries(:one)
    gallery.add_photo(photos(:four))
    assert_equal ['One', 'Two', 'Three', 'Four'], gallery.photos.map{|p| p.title}    
  end

  def test_add_photo_on_position
    gallery = galleries(:one)
    gallery.add_photo(photos(:four), 1)
    assert_equal ['One', 'Four', 'Two', 'Three'], gallery.photos.map{|p| p.title}    
  end

  def test_add_photo_with_move
    gallery = galleries(:two)
    gallery.add_photo(photos(:two), 1)
    assert_equal ['Two'], gallery.photos.map{|p| p.title}    
    assert_equal ['One', 'Three'], galleries(:one).photos.map{|p| p.title}    
  end

  def test_add_wtih_move_in_the_same_geallery
    gallery = galleries(:one)
    gallery.add_photo(photos(:one), 3)
    assert_equal ['Two', 'One', 'Three'], gallery.photos.map{|p| p.title}    
  end

  def test_add_separator
    gallery = galleries(:one)
    gallery.add_separator(1)
    assert_equal ['One', 'Two', 'Three'], gallery.photos.map{|p| p.title}
    assert_equal 4, gallery.gallery_items(true).size
    assert_equal 'GallerySeparator', gallery.gallery_items[1].type

    gallery.add_separator(1)
    assert_equal 4, gallery.gallery_items(true).size

    gallery.add_separator(2)
    assert_equal 4, gallery.gallery_items(true).size

    gallery.add_separator(3)
    assert_equal 5, gallery.gallery_items.size
  end

  def test_remove_photo
    gallery = galleries(:one)
    gallery.remove_photo(photos(:two))
    assert_equal ['One', 'Three'], gallery.photos.map{|p| p.title}
    assert_equal ['Two'], galleries(:one_in_kasiak).photos.map{|p| p.title}
  end

  def test_reorder_items
    gallery = galleries(:one)
    gallery.reorder_items([1, 2, 4, 3])
    assert_equal ['One', 'Three', 'Two'], gallery.photos.map{|p| p.title}
    gallery.reorder_items([3])
    assert_equal ['Two', 'One', 'Three'], gallery.photos(true).map{|p| p.title}
  end
  
end

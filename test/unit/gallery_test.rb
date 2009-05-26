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
    assert_equal ['Two'], galleries(:one_in_syscenter).photos.map{|p| p.title}
  end

  def test_reorder_items
    gallery = galleries(:one)
    gallery.reorder_items([1, 2, 4, 3])
    assert_equal ['One', 'Three', 'Two'], gallery.photos.map{|p| p.title}
    gallery.reorder_items([3])
    assert_equal ['Two', 'One', 'Three'], gallery.photos(true).map{|p| p.title}
  end

  #
  # has_attachment extension tests
  #

  def test_get_attachment
    gallery = galleries(:love_stories)
    assert_equal 'label_love_stories.png', gallery.get_attachment('menu_label').file_name
  end

  def test_set_attachment
    gallery = galleries(:love_stories)
    
    assert_no_difference('AttachmentSlot.count') do
      gallery.set_attachment('menu_label', assets(:love_stories_label_pl))
    end
    assert_equal 'label_love_stories_pl.png', gallery.get_attachment('menu_label').file_name

    assert_difference('AttachmentSlot.count', 1) do
      gallery.set_attachment('banner', assets(:love_stories_banner))
    end
    assert_equal 'love_stories.jpg', gallery.get_attachment('banner').file_name
  end
  
  def test_attachment_slots_with_empty
    gallery = galleries(:love_stories)
    slots = gallery.attachment_slots_with_empty   
    
    assert_equal 'banner', slots[0].name
    assert_nil slots[0].attachment

    assert_equal 'menu_label', slots[1].name
    assert_not_nil slots[1].attachment
  end

  def test_update_attachment_slots
    gallery = galleries(:love_stories)
    data = {
      'banner' => { 
        :attachment_type => 'Asset',
        :attachment_id => assets(:love_stories_banner).id },
      'menu_label' => {},
    }
    
    #assert_no_difference('AttachmentSlot.count') do
    gallery.update_attachment_slots(data)
    #end

    assert_equal assets(:love_stories_banner), gallery.get_attachment('banner')
    assert_nil gallery.get_attachment('menu_label')
    
  end
  
end

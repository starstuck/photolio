require 'test_helper'

# Perform test on gallery object
class ActsAsMenuItemTargetTest < ActiveSupport::TestCase

  def test_get_display_in_default_menu_propery
    assert_equal true, galleries(:one).display_in_default_menu
    assert_equal false, galleries(:one_in_syscenter).display_in_default_menu
  end

  def test_set_display_in_default_menu_propery

    # Clear existing menu item
    assert_no_difference('MenuItem.count()') do
      galleries(:one).display_in_default_menu = false
    end
    assert_difference('MenuItem.count()', -1) do
      assert_equal true, galleries(:one).save
    end
    assert_equal false, galleries(:one).display_in_default_menu
    
    # Create new menu_item    
   assert_no_difference('MenuItem.count()') do
      galleries(:love_stories).display_in_default_menu = true
    end
    assert_difference('MenuItem.count()', 1) do
      galleries(:love_stories).save
    end
    assert_equal true, galleries(:love_stories).display_in_default_menu
  end

  def test_get_default_menu_label
    assert_equal "One", galleries(:one).default_menu_label
    assert_equal "One", galleries(:one).default_menu_label_or_title
    assert_equal nil, galleries(:two).default_menu_label
    assert_equal "Second gallery", galleries(:two).default_menu_label_or_title
    assert_equal nil, galleries(:one_in_syscenter).default_menu_label
  end

  def test_set_default_menu_label
    galleries(:one).default_menu_label = 'Uno'
    assert_equal true, galleries(:one).save
    assert_equal 'Uno', galleries(:one).default_menu_label
    
    galleries(:one).default_menu_label = ''
    assert_equal true, galleries(:one).save
    assert_equal 'First gallery', galleries(:one).default_menu_label_or_title
    
    assert_equal true, galleries(:one).save
  end

  def test_toggle_display_and_set_label_at_once
    g_love = galleries(:love_stories)
    g_love.display_in_default_menu = true
    g_love.default_menu_label = 'Love Long Stories'

    assert_equal true, g_love.save
    assert_equal 'Love Long Stories', Gallery.find(g_love.id).default_menu_label
  end

  def test_set_label_and_toggle_display_at_once
    g_love = galleries(:love_stories)
    g_love.default_menu_label = 'Love Long Stories'
    g_love.display_in_default_menu = true

    assert_equal true, g_love.save
    assert_equal 'Love Long Stories', Gallery.find(g_love.id).default_menu_label
  end

  def test_set_label_and_toggle_display_at_new_object
    g = Gallery.new(:site => sites(:polinostudio),
                    :title => 'Fourth gallery',
                    :display_in_default_menu => true,
                    :default_menu_label => 'Four')
    assert_equal true, g.save    
    assert_equal 'Four', g.default_menu_item.label
  end

end

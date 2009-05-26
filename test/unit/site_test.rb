require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def test_unassigned_photos
    assert_equal ['Four'], sites(:polinostudio).unassigned_photos.map{|p| p.title}
  end

  def test_has_menu
    assert sites(:polinostudio).has_menu? 'galleries'
    assert (not sites(:polinostudio).has_menu? 'clubs')
  end

  def test_get_menu
    assert_not_nil sites(:polinostudio).get_menu('galleries')
    assert_not_nil sites(:pitchouguina).get_menu('galleries')

    assert_raise(Menu::NameError) do
      sites(:polinostudio).get_menu('unknown')
    end
  end

end

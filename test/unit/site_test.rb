require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def test_unassigned_photos
    assert_equal ['Four'], sites(:polinostudio).unassigned_photos.map{|p| p.title}
  end

  def test_site_params
    assert_equal 'x400', sites(:polinostudio).site_params.photo_store_size
  end

end

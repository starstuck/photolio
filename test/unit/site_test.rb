require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def test_unassigned_photos
    assert_equal ['Four'], sites(:polinostudio).unassigned_photos.map{|p| p.title}
  end

end

require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def test_unassigned_photos
    assert_equal ['Four'], sites(:studio).unassigned_photos.map{|p| p.title}
  end

end

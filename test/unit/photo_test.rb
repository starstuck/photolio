require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  def test_update_keywords
    photo = photos(:one)
    photo.update_keywords([{'name' => 'Some Kw'},
                           {'name' => 'Some Kw2'},
                           {'name' => 'Some Kw3'}])
    assert_equal ['Some Kw', 'Some Kw2', 'Some Kw3'], photo.photo_keywords.map{|k| k.name}
  end

  def test_update_participants
    photo = photos(:one)
    photo.update_participants([{'role' => 'One', 'name' => 'Some One'},
                               {'role' => 'Two', 'name' => 'Some Two'}])
    assert_equal ["One: Some One", "Two: Some Two"], photo.photo_participants.map{|k| "#{k.role}: #{k.name}"}
  end


end

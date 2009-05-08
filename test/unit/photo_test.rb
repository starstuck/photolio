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

  def test_update_file_meta
    photo = Photo.new
    file_path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/files/x.png")

    f = File.open(file_path, "r")
    photo.instance_variable_set(:@uploaded_file, f)
    Photo.class_eval "public :update_file_meta"

    photo.update_file_meta

    Photo.class_eval "protected :update_file_meta"
    f.close

    assert_equal 'x.png', photo.file_name
    assert_equal 250, photo.size
    assert_equal 'image/png', photo.mime_type
    assert_equal 12, photo.image_width
    assert_equal 11, photo.image_height
  end

  def test_resized_file_name
    photo = photos(:one)

    assert_equal '_resized/studio/one/160x80.jpg', photo.resized_file_name('x80')
    assert_equal '_resized/studio/one/120x80.jpg', photo.resized_file_name('120x80')
    assert_equal '_resized/studio/one/80x40.jpg', photo.resized_file_name('80x')
  end
end

require 'test_helper'


class HasFileTest < Test::Unit::TestCase

  def setup
    @mime_finder = ModelExtensions::HasFile::MimeFinder.instance
  end 

  def test_mime_type
    assert_equal 'image/png', @mime_finder.mime_type('x.png')
    assert_equal 'image/gif', @mime_finder.mime_type('loading.gif')
  end

end

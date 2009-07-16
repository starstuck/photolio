require 'test_helper'
require 'mini_magick_utils'
require 'base64'

# Gif image 13 x 13 pixels
IMAGE_DATA = "R0lGODlhDQANAIMAADAyMi0vLyorKyYoKCMlJSAhIR0eHhobGxYXFxMUFBAR\nEQ0NDQoKCgYHBwMDAwAAACH+Hmh0dHA6Ly93aWdmbGlwLmNvbS9jb3JuZXJz\naG9wLwAh+QQBAAAPACwAAAAADQANAAAEJRDIKUti7lFp8vsatYAk5ZHfdKLh\nyIKA8ZbrW8xkgoPM/tU+XAQAOw==\n"

class MiniMagickUtilsTest < Test::Unit::TestCase

  def setup
    @image = MiniMagick::Image.from_blob(Base64.decode64(IMAGE_DATA))
  end

  def teardown
    @image = nil
  end

  def test_match_max_size
    assert @image.match_max_size('15x15')
    assert (not @image.match_max_size('10x10'))
    assert @image.match_max_size('15x')
    assert (not @image.match_max_size('10x'))
    assert @image.match_max_size('x15')
    assert (not @image.match_max_size('x10'))
    assert_raise ArgumentError do
      @image.match_max_size('10')
    end      
  end
end

require 'mini_magick'

# Extend MiniMagick Image object with utility functions
class MiniMagick::Image

  # Check if image match size specification
  # Size specification is in format: <width>x<height>
  def match_max_size(size_spec)
    if not size_spec.include? 'x'
      raise ArgumentError.new('Invalid image size definition: ' + size_spec)
    end
    width, height = size_spec.split('x')
    width = width.to_i
    height = height.to_i

    if width == 0
      # test matching height only
      return self[:height] <= height
    elsif height == 0
      # test matching width only
      return self[:width] <= width
    else
      # test matching width and height
      return ((self[:height] <= height) and (self[:width] <= width))
    end
  end  

end

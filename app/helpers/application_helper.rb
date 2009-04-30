module ActionView::Helpers::AssetTagHelper
  alias_method :compute_public_path_without_photolio, :compute_public_path
end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def loading_tag
    loaging_image_tag = image_tag(path_to_image('loading.gif'))
    "<p style=\"text-align: center\">#{loaging_image_tag}"
  end

  # Compute path to photo image. 
  # See Photo.resized_file_name for description of size definition
  def photo_image_path(photo, size=nil)
    if size
        compute_site_public_path(photo.site, photo.resized_file_name(size), 'photos')
    else
        compute_site_public_path(photo.site, photo.file_name, 'photos')
    end
  end
  # alias to avoid resource name colision
  alias_method :path_to_photo_image, :photo_image_path

  # Generate img tag for photo, if only one of with/height attribute is provided,
  # the other one will be calculated from photo aspect ration
  def photo_image_tag(photo, options={})
    opts = {}.update(options)

    if not opts.key? :alt
      opts[:alt] = photo.alt_text
    end

    if opts.key? :size
      size = opts.delete(:size)
      width, height = size.split('x')
      if not width.to_s.empty?
        opts[:width] = width.to_i
      end
      if not height.to_s.empty?
        opts[:height] = height.to_i
      end
    end
      
    if opts.key? :height and opts.key? :width
      size ||= "#{opts[:width]}x#{opts[:height]}"
    elsif opts.key? :height and not opts.key? :width
      size ||= "#x#{opts[:width]}"
      opts[:width] = (opts[:height].to_f * photo.width.to_f / photo.height).to_i
    elsif opts.key? :width and not opts.key? :height
      size ||= "##{opts[:width]}x"
      opts[:height] = (opts[:width].to_f * photo.width.to_f / photo.height).to_i      
    else
      opts[:width] = photo.width
      opts[:height] = photo.height
    end

    opts[:src] = path_to_photo_image(photo, size)
    tag('img', opts)
  end

  protected 

  def compute_site_public_path(site, source, dir, ext=nil)
    compute_public_path_without_photolio(source, "#{site.name}/#{dir}", ext)
  end

end

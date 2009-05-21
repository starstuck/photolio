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
    compute_resized_mixin_file_path(photo, size)
  end
  # alias to avoid resource name colision
  alias_method :path_to_photo_image, :photo_image_path

  # Generate path to asset file.
  def asset_file_path(asset)
    compute_mixin_file_path(asset)
  end
  # alias to avoid resource name colision
  alias_method :path_to_asset_file, :asset_file_path

  def asset_image_path(attachment, size=nil)
    compute_resized_mixin_file_path(asset, size)
  end
  # alias to avoid resource name colision
  alias_method :path_to_asset_image, :asset_image_path

  # Generate img tag for photo, if only one of with/height attribute is provided,
  # the other one will be calculated from photo aspect ration
  def photo_image_tag(photo, options={})
    mixin_file_image_tag(photo, options)
  end

  # Generate img tag for asset
  def asset_image_tag(asset, options={})
    mixin_file_image_tag(asset, options)
  end

  # Render topic with extending macros
  def render_topic(topic)
    # Extract macros with arguments
    rendered = topic.body.gsub(/\[\[([a-z_ ]+)(\(([^\(]*)\))?\s*\]\]/) do |m| 
      macro_name = $1.strip
      args = $3 ? $3.split(',').map{|a| a.strip} : []
      
      if args.size > 0
        if macro_name == 'asset_image_path'
          file_name = args[0]
          compute_site_public_path(topic.site, file_name, Asset.files_folder)
        elsif macro_name == 'photo_image_path'
          file_name = args[0]
          compute_site_public_path(topic.site, file_name, Photo.files_folder)
        else
          ''
        end
      else
        ''
      end      
    end
    return rendered
  end

  protected 

  def compute_site_public_path(site, source, dir, ext=nil)
    compute_public_path_without_photolio(source, "#{site.name}/#{dir}", ext)
  end

  def compute_mixin_file_path(obj)
    compute_site_public_path(obj.site, obj.file_name, obj.class.files_folder)
  end

  def compute_resized_mixin_file_path(obj, size=nil)
    if not size
      compute_mixin_file_path(obj)
    else
      compute_site_public_path(obj.site, obj.resized_file_name(size), obj.class.files_folder)
    end
  end

  def mixin_file_image_tag(obj, options={})
    opts = {}.update(options)

    if (not opts.key? :alt) and opts.key?(:backup_alt) and obj.image_alt.to_s.empty?
      opts[:alt] = opts.delete(:backup_alt)
    end
    if not opts.key? :alt
      opts[:alt] = obj.image_alt
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
      opts[:width] = (opts[:height].to_f * obj.image_width.to_f / obj.image_height).to_i
    elsif opts.key? :width and not opts.key? :height
      size ||= "##{opts[:width]}x"
      opts[:height] = (opts[:width].to_f * obj.image_height.to_f / obj.image_width).to_i      
    else
      opts[:width] = obj.image_width
      opts[:height] = obj.image_height
    end

    opts[:src] = compute_resized_mixin_file_path(obj, size)
    tag('img', opts)
  end

end

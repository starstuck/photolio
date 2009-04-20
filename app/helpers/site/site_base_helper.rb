module ActionView::Helpers::AssetTagHelper
  alias_method :compute_public_path_without_site, :compute_public_path
end

module Site::SiteBaseHelper

  def site_controller_path(site, obj, controller, action, id_method, options={})
    options[:format] = 'html' unless options.key? 'format'
    options[:published] = params[:published] unless options.key? 'published'
    id_value = (id_method and id_method != '') ? obj.send(id_method) : obj
    @controller.send("#{action}_site_#{controller}_path", site.name, id_value, options)
  end

  # Register paths calculation function with user friendly names
  for controller, actions, id_method in [['gallery', ['show'], 'name'],
                                         ['photo', ['show'], 'id'],
                                         ['topic', ['show'], 'name'],
                                        ]
    for action in actions
      class_eval <<-EOS
        def #{action}_site_#{controller}_path(site, obj, options={})
          site_controller_path(site, obj, '#{controller}', '#{action}', '#{id_method}', options)
        end
      EOS
    end
  end

  def site_default_path(site)
    show_site_gallery_path(site, site.galleries_in_order.first)
  end

  def compute_photo_path(photo)
    compute_public_path(photo.file_name, 'photos')
  end

  def compute_photo_thumbnail_path(size, photo)
    compute_public_path(photo.thumbnail_path(size), 'photos')
  end


  protected

  def compute_public_path(source, dir, ext=nil)
    compute_public_path_without_site(source, "#{@site.name}/#{dir}", ext)
  end

end

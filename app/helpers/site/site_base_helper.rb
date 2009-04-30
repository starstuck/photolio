module Site::SiteBaseHelper

  def site_controller_path(site, obj, controller, action, id_method, options={})
    options[:format] = 'html' unless options.key? 'format'
    id_value = (id_method and id_method != '') ? obj.send(id_method) : obj
    path = @controller.send("#{action}_site_#{controller}_path", site.name, id_value, options)
    if params[:published]
      site_prefix = "/#{@site.name}"
      site_prefix_range = 0..(site_prefix.size-1)
      if path[site_prefix_range] == site_prefix
        path[site_prefix_range] = ''
      end
      if @site.site_params.published_url_prefix
        path = @site.site_params.published_url_prefix + path
      end
    end
    path
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

  protected

  def compute_public_path(source, dir, ext=nil)
    path = compute_public_path_without_photolio(source, "#{@site.name}/#{dir}", ext)
    if params[:published]
      site_prefix = "/#{@site.name}"
      if host = ActionController::Base.asset_host
        site_prefix = host + site_prefix
      end
      site_prefix_range = 0..(site_prefix.size-1)
      if path[site_prefix_range] == site_prefix
        path[site_prefix_range] = ''
      end
      if @site.site_params.published_assets_url_prefix
        path = @site.site_params.published_assets_url_prefix + path
      end
    end
    path
  end

  def compute_site_public_path(site, source, dir, ext=nil)
    if site.id == @site.id
      compute_public_path(source, dir, ext=nil)
    else
      raise RuntimeError('Using assets from foreign sites is currently unsupported')
    end
  end

end

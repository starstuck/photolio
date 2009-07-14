module Site::BaseHelper

  def site_controller_path(site, obj, controller, action, id_method, options={})
    options[:format] = 'html' unless options.key? 'format'

    if controller == 'site'
      route_name = "site"
    else
      route_name = "site_#{controller}"
    end

    if obj.is_a? String or obj.is_a? Integer
      id_value = obj
    elsif obj and id_method
      id_value = (id_method and id_method != '') ? obj.send(id_method) : obj
    end

    if ['show'].include? action
      if id_value
        path = @controller.send("#{action}_#{route_name}_path", site.name, id_value, options)
      else
        path = @controller.send("#{action}_#{route_name}_path", site.name, options)
      end
    else
      if id_value
        path = @controller.send("dispatch_#{route_name}_path", site.name, id_value, action, options)
      else
        path = @controller.send("dispatch_#{route_name}_path", site.name, action, options)
      end
    end      

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
      raise RuntimeError.new('Using assets from foreign sites is currently unsupported')
    end
  end

end

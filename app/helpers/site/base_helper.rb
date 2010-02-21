module Site::BaseHelper

  protected

  # Calculate page path, arguments are in order, can be skipped:
  #   controller_name
  #   controller_context
  #   action_name
  #   action_context
  #   options that will be forwarde to underlying url_for command
  def page_path(site, controller, action, *args)
    
    site_controller_base_path = SiteIntrospector.introspect(site).theme_name
    options = {
      :format => 'html',
      :only_path => true,
      :controller => "/site/#{site_controller_base_path}/#{controller}",
      :site_name => site.name,
      :action => action }

    if args[-1].is_a? Hash
      options.update(args.pop)
    end

    # Extract arguments array in order of aperance
    if controller != 'site'
      arg = args.shift
      if arg
        if not arg.is_a? String 
          cinfo = SiteIntrospector.introspect(site).controller_info(controller)
          arg = [arg] if not is_a? Array
          arg = cinfo.context_packer.call(arg)
        end
        options[:controller_context] = arg
      end
    end
    arg = args.shift
    options[:action_context] = arg if arg

    path = url_for(options)

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

  def compute_public_path(source, dir, ext=nil)
    theme_path = SiteIntrospector.introspect(@site).theme_name
    path = compute_public_path_without_photolio(source, "#{theme_path}/#{dir}", ext)
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

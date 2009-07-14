class Site::BaseController < ApplicationController

  before_filter :setup_site_context
  layout :site_layout

  def dispatch
    method_name = params[:method_name]
    theme_name = @site.name

    # TODO: check if method name is defined for theme

    # Extend controller with site defined extensions
    begin
      self.extend eval("Site::#{theme_name.camelize}::#{self.class.name.split(':')[-1]}Extension")
    rescue NameError; end

    # Include site definded helpers
    h_modules = [build_named_routes_helper(theme_name)]
    h_base_name = "Site::#{theme_name.camelize}::"
    begin
      h_modules << eval("#{h_base_name}BaseHelper")
    rescue NameError; end
    begin
      h_modules << eval("#{h_base_name}#{self.class.name.split(':')[-1].gsub(/Controller$/,'')}Helper")
    rescue NameError; end
    for h_module in h_modules
      response.template.helpers.send(:include, h_module)
    end
    
    # Twek attribute storing action named, which is used in view searches
    self.action_name = method_name

    self.send method_name
  end

  protected

  # Get controller path relative to site. Used by Rails in view path calculations
  def controller_path
    @controller_path ||= "site/#{@site.name}/" + \
        self.class.name.gsub(/^Site::/, '').gsub(/Controller$/, '').underscore
  end

  def setup_site_context
    if not @site = Site.find_by_name(params[:site_name])
      raise ActiveRecord::RecordNotFound.new("Site '#{params[:site_name]}' not found") 
    end
  end

  # Coumpute site layout
  def site_layout
    "site/#{@site.name}/layouts/application"
  end

  # Call block only if request last modified is older then argument. It also records
  # database lat_modified time.
  def on_modified last_modified, &block
    @last_modified = last_modified
    # TODO: make precise enough in sites and uncomment here
    #unless @test_last_modified_only
    #  if stale?( :last_modified => @last_modified )
    block.call  
    #  end
    #end
  end

  attr_reader :last_modified

  # Build module with named routes paths methods
  def build_named_routes_helper(theme_name)
    if Rails.configuration.cache_classes
      @@cached_named_routes_helpers ||= {}
      if @@cached_named_routes_helpers.key? theme_name
        return @@cached_named_routes_helpers[theme_name]
      end
    end
    
    mod = Module.new
    for controller, id_method in [['site', nil],
                                  ['gallery', 'name'],
                                  ['photo', 'id'],
                                  ['topic', 'name'],
                                 ]
      begin 
        controller_extension = eval("Site::#{theme_name.camelize}::#{controller.camelize}ControllerExtension")
      rescue NameError; 
        controller_extension = nil
      end
      if controller_extension
        controller_path_part = (controller != 'site') ? "site_#{controller}" : controller
        if id_method
          obj_arg = 'obj, '
          obj_val = 'obj'
        else
          obj_arg = ''
          obj_val = 'nil'
        end
        for action in controller_extension.public_instance_methods.reject{|x| x.starts_with? 'page_info_for'}
          mod.class_eval <<-EOS
            def #{action}_#{controller_path_part}_path(site, #{obj_arg}options={})
              site_controller_path(site, #{obj_val}, '#{controller}', '#{action}', '#{id_method}', options)
            end
          EOS
        end
      end
    end

    if Rails.configuration.cache_classes
      @@cached_named_routes_helpers[theme_name] = mod
    end

    mod
  end

end

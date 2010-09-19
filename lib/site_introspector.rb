module SiteIntrospector

  SUPPORTED_CONTROLLERS = %w(site gallery topic photo)

  class SiteInfo
    
    attr_reader :site 

    def self.instance(controller_class)
      @@__instances__ ||= {}
      if not @@__instances__.key? controller_class.name
        @@__instances__[controller_class.name] = ControllerInfo.new(controller_class)
      end
      @@__instances__[controller_class.name]
    end

    def self.instance(site)
      @@__instances__ ||= {}
      if not @@__instances__.key? site.name
        @@__instances__[site.name] = SiteInfo.new(site)
      end
      @@__instances__[site.name]
    end

    def initialize(site)
      @site = site
    end

    private :initialize

    
    def theme_name
      if ! @theme_name
        @theme_name =  SiteParams.for_site(site).theme || site.name
      end
      return @theme_name
    end

    def iterate_inherited_themes
        template_obj = SiteParams.for_site(site)
        template_class = template_obj.class
        while template_class and template_class != SiteParams::DefaultParams
          yield(template_obj)
          template_class = template_class.superclass
          template_obj = template_class.new(site)
        end
    end

    # return list of inherited themes info objects, starting from current object
    def inherited_themes
      result = []
      iterate_inherited_themes { |t| result << t }
      return result
    end
    
    # Theme public path in order by preference, starting with prefered one
    def theme_public_paths
      if ! @theme_public_paths
        @theme_public_paths = []
      end
      iterate_inherited_themes { |t| @theme_public_paths << t.theme }
      @theme_public_paths.uniq!
      return @theme_public_paths
    end

    # Return array of Controller info objects for controller defined for site      
    def controllers_infos
      controllers_infos_hash.values
    end

    # Return controller info by method name
    def controller_info(name)
      controllers_infos_hash[name]
    end

    private

    def controllers_infos_hash
      unless @controllers_infos_hash
        @controllers_infos_hash = {}
        for controller in SUPPORTED_CONTROLLERS
          begin 
            controller_class = eval("Site::#{theme_name.camelize}::#{controller.camelize}Controller")
          rescue NameError; 
            controller_class = nil
          end
          if not controller_class.nil?
            @controllers_infos_hash[controller] = ControllerInfo.instance(controller_class)
          end
        end
      end
      @controllers_infos_hash
    end

  end
  

  class ControllerInfo
    
    attr_reader :controller_class

    def self.instance(controller_class)
      @@__instances__ ||= {}
      if not @@__instances__.key? controller_class.name
        @@__instances__[controller_class.name] = ControllerInfo.new(controller_class)
      end
      @@__instances__[controller_class.name]
    end

    def initialize(controller_class)
      @controller_class = controller_class
    end
 
    private :initialize

    # Underscored controller names
    def name
      @name ||= controller_class.name.gsub(/^.*::/, '').gsub(/Controller$/,'').underscore
    end

    def path
      @path ||= controller_class.name.gsub(/Controller$/,'').underscore
    end

    def default_page
      :show
    end

    # List page names defined in controller.
    def pages_keys
      controller_pages_infos_hash.keys
    end

    # List page information objects defined in controller.
    def pages_infos
      controller_pages_infos_hash.values
    end

    # Return papage info by method name
    def page_info(name)
      controller_pages_infos_hash[name]
    end

    def context_names
      controller_context_info_hash[:attribute_names]
    end

    def context_extractor
      controller_context_info_hash[:extractor]
    end

    def context_packer
      controller_context_info_hash[:packer]
    end

    def context_iterator
      controller_context_info_hash[:iterator]
    end

    # Setup controller context using values form params
    def setup_context(controller, params)
      site = controller.instance_variable_get(:@site)
      vals = context_extractor.call(site, params[:controller_context])
      vals = vals.reject{|x| x.nil?}
      if vals.size == context_names.size
        for name, val in [context_names, vals].transpose
          controller.instance_variable_set("@#{name.to_s}".to_sym, val)
        end
      else
        raise ActiveRecord::RecordNotFound.new("Context identified by '#{params[:controller_context]}' not found in '#{site.name}' site")
      end
    end

    private

    def controller_pages_infos_hash
      controller_class.instance_variable_get(:@pages_infos) || {}
    end

    def controller_context_info_hash
      unless @info
        cls = controller_class
        while cls and not @info
          @info = cls.instance_variable_get(:@context_info)
          cls = cls.superclass
        end
        @info ||= {}
      end
      @info
    end

  end


  # Page info object
  class PageInfo
    
    attr_reader :name
    attr_reader :options
    
    def initialize(name, options)
      @name = name
      update(options)
    end
    
    def update(options)
      @options ||= {}
      @options.update(options)
    end
    
    # Additional sitemap page info, like changefreq, or priority
    def sitemap_info
      options[:sitemap_info] || {}
    end

    # Does page apear in istemap
    def in_sitemap?
      if options[:in_sitemap]
        return options[:in_sitemap]
      else
        return true
      end
    end

    # Page supported formats
    def formats
      options[:formats]
    end

    # Page action context iterator
    def context_iterator
      options[:context_iterator]
    end

  end
    

  # Conttroller class methods for describing pages
  module ControllerClassMethods
    
    # Declare method acting as page
    def acts_as_page(method_sym, options={})
      method_sym = method_sym.to_sym
      @pages_infos ||= {}
      if not @pages_infos.key? method_sym
        @pages_infos[method_sym] = PageInfo.new(method_sym, options)
      else
        @pages_infos[method_sym].update(options)
      end
    end

    # Decare controller context handling routines
    #
    # Params:
    #   names - names of controller attributes, that will be set for extracted context
    #   extractor - method for extracting object values form url names
    #   packer - moethod for buildingurl context string from values. reverse to extractor
    #   iterator = method for iterating whole context for site. User in site maps    
    def setup_controller_context names, extractor, packer, iterator
      if not names.is_a? Array
        names =[names]
      end
      @context_info = {
        :attribute_names => names,
        :extractor => extractor,
        :packer => packer,
        :iterator => iterator
      }
      class_eval <<-EOS
        before_filter :setup_controller_context
        private
        def setup_controller_context
          SiteIntrospector::ControllerInfo.instance(self.class).setup_context(self, params)
        end
      EOS
    end

  end

  
  def self.introspect(site)
    SiteInfo.instance(site)
  end

end

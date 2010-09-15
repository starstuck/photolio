class Site < ActiveRecord::Base

  has_attachment

  belongs_to :parent, :class_name => 'Site'
  has_many :children, :class_name => 'Site', :foreign_key => 'parent_id', :dependent => :nullify, :order => 'name'
  has_many :assets, :dependent => :destroy, :order => 'file_name'
  has_many :galleries, :dependent => :destroy, :order => 'name' 
  has_many :topics, :dependent => :destroy, :order => 'title'
  has_many :menus, :dependent => :destroy, :order => 'name'
  has_and_belongs_to_many :users, :order => 'name, login', :uniq => true

  has_shared :photos, :dependent => :destroy, :order => 'file_name'

  validates_length_of :name, :in => 3..255
  validates_uniqueness_of :name

  # List of photos not assigned to any gallery
  def unassigned_photos
    assigend_photos_ids = {}
    for gal in galleries
      for item in gal.gallery_items
        assigend_photos_ids[item.photo_id] = true unless assigend_photos_ids.key? item.photo_id
      end
    end
    return Photo.find(photos.reject{|x| assigend_photos_ids.key? x.id}, 
                      :order => 'file_name')
  end

  # Get site template options object
  def site_params
    @site_params ||= SiteParams.for_site(self)
  end

  # Aliast to self object, for compatybility with other site entities
  def site
    self
  end

  # Site theme name
  def theme_name
    @theme_name ||= SiteIntrospector.introspect(self).theme_name
    return @theme_name
  end
  
  # Check if site has menu with provided name
  def has_menu?(name)
    return(site_params.menus and site_params.menus.include? name)
  end

  # Get or create site menu, by menu name
  def get_menu(name)
    menu = menus.find_or_create_by_name(name)
    unless menu.errors.empty?
      raise Menu::NameError.new(menu.errors.full_messages.join(', '))
    end
    menu
  end

  # Pool of sitest which can share items with curent site
  def share_pool
    @share_pool ||= compute_share_pool
    return @share_pool
  end

  private

  def compute_share_pool
    if parent
      sites = parent.share_pool.reject{|s| s.id == id}
      sites.unshift parent
    else
      sites = []
      def collect_children (sites, c)
        c.children.map{|s| sites << s}
      end
      collect_children(sites, self)
    end

    return sites
  end

end

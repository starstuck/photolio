module Site::Polinostudio::BaseHelper

  def site_default_path(site)
    menu = site.get_menu('galleries')
    show_site_gallery_path(site, menu.menu_items[0].target)
  end
  
end

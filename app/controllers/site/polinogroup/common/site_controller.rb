class Site::Polinogroup::Common::SiteController < Site::SiteController

  acts_as_page(:load, :skip_sitemap => true)
  acts_as_page(:show, :skip_sitemap => false) # :no_publish => true)

  def load
    render :layout => false
  end

  def show
    # TODO: make initial page dynamicaly calculated
    begin
      default_gallery = @site.get_menu('galleries').menu_items.first.target.name
    rescue Menu::NameError
      default_gallery = @site.galleries.first.name  
    end
    render :layout => false
  end

end 

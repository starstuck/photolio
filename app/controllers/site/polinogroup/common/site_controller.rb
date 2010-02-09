class Site::Polinogroup::Common::SiteController < Site::SiteController

  acts_as_page(:show,
               :skip_sitemap => true,
               :no_publish => true
               )
  
  def show  
    begin
      gname = @site.get_menu('galleries').menu_items.first.target.name
    rescue Menu::NameError
      gname = @site.galleries.first.name  
    end
    redirect_to(url_for(:controller => site_views_path + '/gallery',
                        :action => 'show',
                        :site_name => @site.name,
                        :controller_context => gname,
                        :format => 'html' ),
                :status => 307 )
  end

end 

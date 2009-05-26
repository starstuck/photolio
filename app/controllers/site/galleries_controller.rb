class Site::GalleriesController < Site::SiteBaseController
  
  def show
    begin 
      render :template => template_for('galleries'), :layout => layout
    rescue ActionView::MissingTemplate 
      begin
        gname = @site.get_menu('galleries').menu_items.first.target.name
      rescue Menu::NameError
        gname = @site.galleries.first.name
      end        
      redirect_to( :controller => 'gallery',
                   :action => 'show',
                   :gallery_name => gname,
                   :format => 'html',
                   :status => 307  )
    end
  end

end

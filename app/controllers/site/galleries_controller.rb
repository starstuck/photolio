class Site::GalleriesController < Site::SiteBaseController
  
  def show
    begin 
      render :template => template_for('galleries'), :layout => layout
    rescue ActionView::MissingTemplate 
      redirect_to( :controller => 'gallery',
                   :action => 'show',
                   :gallery_name => @site.galleries_in_order.first.name, 
                   :format => 'html',
                   :status => 307  )
    end
  end

end

class Site::GalleryController < Site::SiteBaseController

  before_filter :setup_gallery_context
  
  def show
    @galleries = @site.galleries_in_order
    @menu_items = @site.topics.find(:all, :conditions => 'display_in_menu <> 0' )

    respond_to do |format|
      format.html { render :template => (template_for :gallery), :layout => layout }
      format.parthtml { render :template => (template_for :gallery), :layout => false }
    end
  end

  private

  def setup_gallery_context
    @gallery = @site.galleries.find( :first, :conditions => { 'name' => params[:gallery_name] } )
  end

end

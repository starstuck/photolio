class GalleryController < ApplicationController

  before_filter :setup_context
  
  def show
    @galleries = @site.galleries_in_order
    @menu_items = @site.topics.find(:all, :conditions => 'display_in_menu <> 0' )

    respond_to do |format|
      format.html 
      format.parthtml { render :template => 'gallery/show.html.erb', :layout => false }
    end
  end

  private

  def setup_context
    @site = Site.find( :first, :conditions => { 'name' => params[:site_name] } )
    @gallery = @site.galleries.find( :first, :conditions => { 'name' => params[:gallery_name] } )
  end

end

class PhotoController < ApplicationController
  
  before_filter :setup_context

  def show
    respond_to do |format|
      format.html
      format.parthtml { render :template => 'photo/show.html.erb', :layout => false }
    end
  end

  private

  def setup_context
    @site = Site.find( :first, :conditions => { 'name' => params[:site_name] } )
    @photo = @site.photos.find(params[:photo_id])
  end


end

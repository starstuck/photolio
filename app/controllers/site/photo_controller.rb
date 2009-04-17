class Site::PhotoController < Site::SiteBaseController
  
  before_filter :setup_photo_context

  def show
    respond_to do |format|
      format.html { render :template => (template_for :photo), :layout => layout }
      format.parthtml { render :template => (template_for :photo), :layout => false }
    end
  end

  private

  def setup_photo_context
    @photo = @site.photos.find(params[:photo_id])
  end


end

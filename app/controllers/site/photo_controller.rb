class Site::PhotoController < Site::BaseController
  
  before_filter :setup_photo_context

  private

  def setup_photo_context
    @photo = @site.photos.find(params[:photo_id])
  end

end

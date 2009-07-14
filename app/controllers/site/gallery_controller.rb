class Site::GalleryController < Site::BaseController

  before_filter :setup_gallery_context

  private

  def setup_gallery_context
    if not @gallery = @site.galleries.find_by_name(params[:gallery_name])
      raise ActiveRecord::RecordNotFound.new("Gallery '#{params[:gallery_name]}' not found in '#{@site.name}' site")
    end
  end

end

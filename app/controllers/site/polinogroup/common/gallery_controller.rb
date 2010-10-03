class Site::Polinogroup::Common::GalleryController < Site::GalleryController

  acts_as_page( :show, 
                :sitemap_info =>  
                { :priority => '0.8',
                  :changefreq => 'daily' }
                )

  def show
    if params[:format] == 'parthtml'
      params[:format] = 'html'
      render :layout => false, :format => 'html'
    end
  end

end 

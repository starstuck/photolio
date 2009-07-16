class Site::Pitchouguina::GalleryController < Site::GalleryController

  acts_as_page( :show, 
                :sitemap_info =>  
                { :priority => '0.8',
                  :changefreq => 'daily' }
                )

  def show
  end

end 

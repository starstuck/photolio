class Site::Polinogroup::Common::PhotoController < Site::PhotoController

  acts_as_page( :show,
                :sitemap_info =>  
                { :priority => '0.2',
                  :changefreq => 'weekly' }
                )

  def show
  end

end 

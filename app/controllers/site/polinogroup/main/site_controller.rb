class Site::Polinogroup::Main::SiteController < Site::Polinogroup::Common::SiteController

  acts_as_page(:show,
                :sitemap_info =>  
                { :priority => '0.4',
                  :changefreq => 'daily' }
                )
  
  def show
  end

end 

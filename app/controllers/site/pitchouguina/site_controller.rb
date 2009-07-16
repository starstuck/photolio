class Site::Pitchouguina::SiteController < Site::SiteController

  acts_as_page( :show, 
                :sitemap_info =>  
                { :priority => '0.5',
                  :changefreq => 'weekly' }
                )

  def show
  end
  
  acts_as_page( :galleries,
                :sitemap_info =>  
                { :priority => '0.8',
                  :changefreq => 'daily' }
                )

  def galleries
  end

end 

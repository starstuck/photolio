class Site::Polinogroup::Main::SiteController < Site::Polinogroup::Common::SiteController

  acts_as_page(:show,
                :sitemap_info =>  
                { :priority => '0.4',
                  :changefreq => 'daily' }
                )
  # TODO: this information should b inherited from master template
  acts_as_page(:load, :skip_sitemap => true)
  
  def show
    render :layout => 'site/polinogroup/common/layouts/application'
  end

  # TODO: template should be found from inheritance
  def load
    render :layout => false, :template => 'site/polinogroup/common/site/load.html.erb'
  end

end 

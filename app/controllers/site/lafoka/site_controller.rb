class Site::Lafoka::SiteController < Site::SiteController

  layout false # There was proble with render_component when layout disabled on
               # render method invocation level

  acts_as_page( :show,
                :sitemap_info =>
                { :priority => '0.5',
                  :changefreq => 'weekly' }
                )

  def show
  end
  
end 

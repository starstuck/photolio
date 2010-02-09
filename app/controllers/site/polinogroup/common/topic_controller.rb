class Site::Polinogroup::Common::TopicController < Site::TopicController

  acts_as_page( :show,
                :sitemap_info =>  
                { :priority => '0.6',
                  :changefreq => 'daily' }
                )

  def show
  end

end 

class Site::Polinogroup::Main::TopicController < Site::TopicController

  acts_as_page( :show,
                :formats => ['html', 'parthtml'],
                :sitemap_info =>  
                { :priority => '0.6',
                  :changefreq => 'daily' }
                )

  def show
  end

end 

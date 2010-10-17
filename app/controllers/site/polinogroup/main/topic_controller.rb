class Site::Polinogroup::Main::TopicController < Site::Polinogroup::Common::TopicController

  acts_as_page( :show,
                :formats => ['html', 'parthtml'],
                :sitemap_info =>  
                { :priority => '0.6',
                  :changefreq => 'daily' }
                )

  # TODO: this should somehow be from inheritance
  layout 'site/polinogroup/common/layouts/application'

  # TODO: Also inheritance should solve this
  def show
    render :template => 'site/polinogroup/common/topic/show'
  end
end 

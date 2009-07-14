module Site::Pitchouguina::TopicControllerExtension

  def page_info_for_show
    { :priority => '0.6',
      :changefreq => 'daily'
    }
  end

  def show
    on_modified @topic.updated_at do
      render
    end
  end

end 

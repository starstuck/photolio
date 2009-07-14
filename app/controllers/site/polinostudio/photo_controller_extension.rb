module Site::Polinostudio::PhotoControllerExtension

  def page_info_for_show
    { :priority => '0.2',
      :changefreq => 'weekly'
    }
  end

  def show
    on_modified @photo.updated_at do
      render
    end
  end

end 

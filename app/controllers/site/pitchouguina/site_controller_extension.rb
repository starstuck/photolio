module Site::Pitchouguina::SiteControllerExtension

  def page_info_for_show
    { :priority => '0.5',
      :changefreq => 'weekly'
    }
  end

  def show
    on_modified @site.updated_at do
      render
    end
  end
  
  def page_info_for_galleries
    { :priority => '0.8',
      :changefreq => 'weekly'
    }
  end

  def galleries
    on_modified @site.updated_at do
      render
    end
  end

end 

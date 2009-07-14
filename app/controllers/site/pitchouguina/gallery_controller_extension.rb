module Site::Pitchouguina::GalleryControllerExtension

  def page_info_for_show
    { :priority => '0.8',
      :changefreq => 'daily'
    }
  end

  def show
    last_modified = [@gallery.updated_at, @site.updated_at].max
    on_modified last_modified do
      render
    end
  end

end 

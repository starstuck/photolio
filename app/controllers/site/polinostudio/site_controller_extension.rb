module Site::Polinostudio::SiteControllerExtension

  def page_info_for_show
    { :skip_sitemap => true,
      :no_publish => true }
  end

  def show
    on_modified (@site.updated_at) do
      begin
        gname = @site.get_menu('galleries').menu_items.first.target.name
      rescue Menu::NameError
        gname = @site.galleries.first.name  
      end
      redirect_to(show_site_gallery_path(:gallery_name => gname, :format => 'html'),
                  :format => 'html',
                  :status => 307  )
    end
  end

end 

module Site::Lafoka::SiteHelper

  def show_default_gallery_path
    page_site_gallery_path(@site, @site.galleries[0], 1)
  end

end

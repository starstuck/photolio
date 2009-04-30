require 'publisher'


class Site::SiteController < Site::SiteBaseController

  # redirect to default gallery if page template does not exists
  def show
    begin 
      render :template => (template_for :site), :layout => layout
    rescue ActionView::MissingTemplate 
      redirect_to( :controller => 'gallery',
                   :action => 'show',
                   :gallery_name => @site.galleries_in_order.first.name, 
                   :format => 'html',
                   :status => 307  )
    end
  end

  def sitemap
    if params[:published]
      publisher = Publisher::publisher_for_location(self, @site)
    end

    @sitemap = Site::SiteController.raw_sitemap(@site).map do |item|
      if params[:published]
        item[:url] = publisher.compute_page_url(item[:loc])
      else
        item[:url] = url_for(item[:loc])
      end
      item
    end

    respond_to do |format|
      format.xml { render :template => 'site/sitemap', :layout => false}
    end
  end

  # compute raw_sitemap
  def self.raw_sitemap(site)
    sitemap = []

    # Calcualte times for menu items
    last_gallery_updated = Gallery.maximum('updated_at')
    last_topic_updated = Topic.maximum('updated_at')
    
    # add gelleries_pages
    for gallery in site.galleries
      last_item_assigned = GalleryItem.maximum('updated_at', :conditions => ['gallery_id = ?', gallery.id])
      last_photo_updated = Photo.maximum('updated_at', :conditions => ['id in (?)', gallery.photo_ids])
      sitemap << { 
        :loc => { 
          :controller => '/site/gallery',
          :action => 'show',
          :site_name => gallery.site.name,
          :gallery_name => gallery.name,
          :format => 'html',
        },
        :lastmod => [ last_gallery_updated, 
                       last_topic_updated, 
                       last_item_assigned,
                       last_photo_updated ].reject{|x| x == nil}.max,
        :changefreq => 'daily',
        :priority => '0.8'
      }
    end

    # add topic pages
    for topic in site.topics
      sitemap << { 
        :loc => { 
          :controller => '/site/topic',
          :action => 'show',
          :site_name => gallery.site.name,
          :topic_name => topic.name,
          :format => 'html',
        },
        :lastmod => topic.updated_at,
        :changefreq => 'daily',
        :priority => '0.6'
      }
    end

    # add photos pages
    hidden_photos = site.unassigned_photos
    for photo in site.photos
      unless hidden_photos.include? photo
        sitemap << { 
          :loc => { 
            :controller => '/site/photo',
            :action => 'show',
            :site_name => gallery.site.name,
            :photo_id => photo.id,
            :format => 'html',
          },
          :lastmod => topic.updated_at,
          :changefreq => 'weekly',
          :priority => '0.2'
          }
      end
    end

    sitemap
  end

end

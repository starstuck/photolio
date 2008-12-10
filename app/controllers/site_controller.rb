class SiteController < ApplicationController

  before_filter :setup_context

  # redirect to default gallery
  def index
    @gallery = @site.galleries_in_order.first
    redirect_to( :controller => 'gallery',
                 :action => 'show',
                 :gallery_name => @gallery.name, 
                 :format => 'html',
                 :status => 307  )
  end

  def sitemap
    @sitemap = SiteController.raw_sitemap(@site)
    @url_prefix = 'http://www.polinostudio.com'
    respond_to do |format|
      format.xml { render :layout => false}
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
        'loc' => { 
          'controller' => 'gallery',
          'action' => 'show',
          'site_name' => gallery.site.name,
          'gallery_name' => gallery.name
        },
        'lastmod' => [ last_gallery_updated, 
                       last_topic_updated, 
                       last_item_assigned,
                       last_photo_updated ].reject{|x| x == nil}.max,
        'changefreq' => 'daily',
        'priority' => '0.8'
      }
    end

    # add topic pages
    for topic in site.topics
      sitemap << { 
        'loc' => { 
          'controller' => 'topic',
          'action' => 'show',
          'site_name' => gallery.site.name,
          'topic_name' => topic.name
        },
        'lastmod' => topic.updated_at,
        'changefreq' => 'daily',
        'priority' => '0.6'
      }
    end

    # add photos pages
    hidden_photos = site.unassigned_photos
    for photo in site.photos
      unless hidden_photos.include? photo
        sitemap << { 
          'loc' => { 
            'controller' => 'photo',
            'action' => 'show',
            'site_name' => gallery.site.name,
            'id' => photo.id
          },
          'lastmod' => topic.updated_at,
          'changefreq' => 'weekly',
          'priority' => '0.2'
          }
      end
    end


    sitemap
  end

  private

  def setup_context
    @site = Site.find( :first, :conditions => { 'name' => params[:site_name] } )
  end

end

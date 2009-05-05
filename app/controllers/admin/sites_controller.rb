require 'publisher'


class Admin::SitesController < Admin::AdminBaseController

  before_filter :setup_site_context
  skip_before_filter :setup_site_context, :only => [:index, :new, :create]

  before_filter :sites_manager_required, :only => [:new, :create]


  # GET /admin_sites
  # GET /admin_sites.xml
  def index
    if current_user.has_role('sites_manager')
      @sites = Site.find(:all, :order => 'name')
    else
      @sites = current_user.sites.find(:all, :order => 'name')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /admin_sites/1
  # GET /admin_sites/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /admin_sites/new
  # GET /admin_sites/new.xml
  def new
    @site = Site.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /admin_sites/1/edit
  def edit
  end

  # POST /admin_sites
  # POST /admin_sites.xml
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        format.html { redirect_to(admin_sites_path) }
        format.xml  { render :xml => @site, :status => :created, :location => admin_sites_path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_sites/1
  # PUT /admin_sites/1.xml
  def update
    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to(admin_site_path(@site)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_sites/1
  # DELETE /admin_sites/1.xml
  def destroy
    @site.destroy

    respond_to do |format|
      format.html { redirect_to(admin_sites_path) }
      format.xml  { head :ok }
    end
  end

  # Dispaly screen for layouting photos.
  # It allows to assign photos to gallerias, change order, add separators
  def layout
    @galleries = @site.galleries
    
    respond_to do |format|
      format.html # layout.html.erb
      format.xml  { render :xml =>{
          'site' => @site, 
          'galleries' => @galleries
        }}
    end
  end

  def layout_unassigned_photos_partial
    @unassigned_photos = @site.unassigned_photos

    render(:partial => "layout_unassigned_photos",
           :locals => {:unassigned_photos => @unassigned_photos})
  end

  def layout_add_gallery_photo
    @gallery = @site.galleries.find(params[:gallery_id])
    source_gallery_id, photo_id = params[:photo_id].split('_')[-2..-1]
    @photo = @site.photos.find(photo_id)
    if source_gallery_id != 'unassigned'
      @source_gallery = @site.galleries.find(source_gallery_id) 
    end
    position = params[:position].to_i

    if @gallery and @photo
     @gallery.add_photo(@photo, position)
    end
      
    respond_to do |format|

      format.js do
        render :update do |page|
          @gallery.gallery_items(true)
          page.replace_html( "gallery_#{@gallery.id}_photos_list", 
                             :partial => 'layout_gallery_photos', 
                             :locals => { :gallery => @gallery } )
          if @source_gallery
            if @source_gallery.id != @gallery.id
              page.replace_html( "gallery_#{@source_gallery.id}_photos_list", 
                                 :partial => 'layout_gallery_photos', 
                                 :locals => { :gallery => @source_gallery } )
            end
          else
            page.replace_html( "unassigned_photos_list", 
                               :partial => 'layout_unassigned_photos' )
          end
        end
      end
      
      format.xml { head :ok  }
    end
  end

  def layout_remove_gallery_photo
    # We must query for photo object, because @site.photo.find returns photo
    # object with joins data, which brakes @photo.id attribute
    source_gallery_id, photo_id = params[:photo_id].split('_')[-2..-1]
    @photo = @site.photos.find(photo_id)
    @source_gallery = @site.galleries.find(source_gallery_id)

    if @source_gallery
      # If gallery is provided, remove photo only from this gallery
      @source_gallery.remove_photo(@photo)
    else
      # If it is not provided, remove photo from all galleries in site
      @site.galleries.each do |gallery|
        gallery_photo_ids = gallery.gallery_items.map{|item| item.photo_id}
        if gallery_photo_ids.include? @photo.id
          gallery.remove_photo(@photo)
        end
      end
    end

    respond_to do |format|

      format.js do 
        render :update do |page| 
          page.replace_html( "unassigned_photos_list", 
                             :partial => 'layout_unassigned_photos' )
          page.replace_html( "gallery_#{@source_gallery.id}_photos_list", 
                             :partial => 'layout_gallery_photos', 
                             :locals => { :gallery => @source_gallery } )
        end
      end

      format.xml { head :ok  }
    end

  end

  def layout_add_gallery_separator
    @gallery = @site.galleries.find(params[:gallery_id])
    position = params[:position].to_i
      
    @gallery.add_separator(position)
    @gallery.gallery_items(true)

    respond_to do |format|
      format.html { render :partial => 'layout_gallery_photos', :locals => {:gallery => @gallery} }
      format.xml  { head :ok  }
    end
  end
  
  def layout_remove_gallery_separator
    @gallery = @site.galleries.find(params[:gallery_id])
    @separator = @gallery.gallery_items.find(params[:separator_id].split('_')[-1])
    
    @separator.destroy
    @gallery.gallery_items(true)
    
    respond_to do |format|
      format.html { render :partial => 'layout_gallery_photos', :locals => {:gallery => @gallery} }
      format.xml  { head :ok  }
    end
  end

  # Publish page. 
  #
  # Write pages content to files on defined site publish location folder.
  #
  # Publish use module attributes to indicate, that page is being published.
  # This makes publishing not thread save
  # 
  def publish
    publisher = Publisher::publisher_for_location(self, @site)
    
    # Publish all pages from sitemap
    sitemap = Site::SiteController.raw_sitemap(@site)

    galleries_count = 0
    topics_count = 0
    photos_count = 0
    others_count = 0
    max_lastmod = DateTime.new

    for page in sitemap
      published = publisher.publish(page[:loc], page[:lastmod])
      max_lastmod = page[:lastmod] if page[:lastmod] > max_lastmod
        if published
          controller_name = page[:loc][:controller]
          if controller_name =~ /gallery/
            galleries_count += 1
          elsif controller_name =~ /topic/
            topics_count += 1
          elsif controller_name =~ /photo/
            photos_count += 1
          else
            others_count += 1
          end
      end
    end

    # Publish sitemap page
    publisher.publish({ :controller => '/site/site',
                        :action => 'sitemap',
                        :site_name => @site.name,
                        :format => 'xml',
                      }, max_lastmod)

    # Publish site assets 
    # Photo previews should be already generated after page displaying
    publisher.copy_assets_folder
    
    flash[:notice] = "Site #{@site.name} is published. #{galleries_count} galleries, #{topics_count} topics, #{photos_count} photos and #{others_count} other pages updated."

    respond_to do |format|
        format.html { redirect_to(admin_site_path(@site)) }
        format.xml  { head :ok }
    end
  end

  private

  def setup_site_context
    @site = Site.find(params[:id])
    site_manager_or_owner_required
  end

end

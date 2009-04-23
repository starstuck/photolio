# -*- coding: iso-8859-2 -*-
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

  def layout_gallery_photos_partial
    @gallery = @site.galleries.find(params[:gallery_id])

    render(:partial => "layout_gallery_photos",
           :locals => {:gallery => @gallery})
  end

  def layout_unassigned_photos_partial
    @site = Site.find(params[:id])
    @unassigned_photos = @site.unassigned_photos

    render(:partial => "layout_unassigned_photos",
           :locals => {:unassigned_photos => @unassigned_photos})
  end

  def layout_add_gallery_photo
    @gallery = @site.galleries.find(params[:gallery_id])
    @photo = @site.photos.find(params[:photo_id].split('_')[-1])
    position = params[:position].to_i

    if @gallery and @photo
     @gallery.add_photo(@photo, position)
    end
      
    respond_to do |format|
      format.html { layout_gallery_photos_partial }
      format.xml  { head :ok  }
    end
  end

  def layout_remove_gallery_photo
    # We must query for photo object, because @site.photo.find returns photo
    # object with joins data, which brakes @photo.id attribute
    @photo = Photo.find(params[:photo_id].split('_')[-1],
                        :conditions => {:site_id => @site.id})

    if params.key? :gallery_id
      
      # If gallery os provided, remove photo only from this gallery
      gallery = @site.galleries.find(params[:gallery_id])
      gallery.remove_photo(@photo)
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
      format.html { layout_unassigned_photos_partial }
      format.xml  { head :ok  }
    end

  end

  def layout_add_gallery_separator
    @gallery = @site.galleries.find(params[:gallery_id])
    position = params[:position].to_i
      
    @gallery.add_separator(position)

    respond_to do |format|
      format.html { layout_gallery_photos_partial }
      format.xml  { head :ok  }
    end
  end
  
  def layout_remove_gallery_separator
    @gallery = @site.galleries.find(params[:gallery_id])
    @separator = @gallery.gallery_items.find(params[:separator_id].split('_')[-1])
    
    @separator.destroy
    @gallery.gallery_items(true)
    
    respond_to do |format|
      format.html { layout_gallery_photos_partial }
      format.xml  { head :ok  }
    end
  end

  # Pusblish page. First cache all pages in public directory. 
  # If remote location is configured, synchronize this directory with remote location.
  def publish
    sitemap = Site::SiteController.raw_sitemap(@site)
    
    galleries_count = 0
    topics_count = 0
    photos_count = 0
    max_lastmod = DateTime.new

    # TODO optimize, by not deleting old files, only updating based on mtime

    # Clean old published files
    for folder in ['gallery', 'topic', 'photo']
      FileUtils.rm_rf File.join( Rails.public_path, folder )
    end

    # Cache all pages from sitemap
    for page in sitemap
      page_path = save_page(page['loc'], page['lastmod'])

      max_lastmod = page['lastmod'] if page['lastmod'] > max_lastmod
      if page_path =~ /^\/[^\/]*\/gallery\//:
        galleries_count += 1
      elsif page_path =~ /^\/[^\/]*\/topic\//:
        topics_count += 1
      elsif page_path =~ /^\/[^\/]*\/photo\//:
        photos_count += 1
      end
    end

    save_page({ :controller => '/site/site',
                :action => 'sitemap',
                :site_name => @site.name,
                :format => 'xml',
                :published => true
              }, max_lastmod)

    flash[:notice] = "Site #{@site.name} is published. #{galleries_count} galleries, #{topics_count} topics, #{photos_count} photos saved."

    if Site.publish_remote_location
      logger.info "Publishing site to remote location: #{Site.publish_remote_location} ..."
      rsync = IO.popen("rsync --recursive --times #{Rails.public_path}/* #{Site.publish_remote_location}")
      logger.info( rsync.readlines.join("\n") )
      flash[:notice] += " Content copied to remote location."
    end

    respond_to do |format|
        format.html { redirect_to(admin_site_path(@site)) }
        format.xml  { head :ok }
    end
  end

  private

  # Save page to file, and set ctime acording to lastmod
  # Returns page path (relative to server root)
  def save_page(location, ctime)
    page_params = location.clone
    page_controller = page_params.delete(:controller)
    page_action = page_params.delete(:action)
    body = render_component_as_string( :controller => page_controller,
                                       :action => page_action,
                                       :params => page_params )
    
    page_path = url_for( location.merge( :only_path => true, :skip_relative_url_root => true ) )
    page_file_path = File.join( Rails.public_path, page_path )
    FileUtils.mkdir_p( File.dirname( page_file_path ) )
    File.open(page_file_path, "wb+"){ |f| f.write(body) }
    
    if ctime.is_a? DateTime
      ctime = ctime.to_time
    elsif ctime.is_a? ActiveSupport::TimeWithZone
      ctime = ctime.time
    end        
    File.utime(Time.new, ctime, page_file_path)
    
    return page_path
  end

  def setup_site_context
    @site = Site.find(params[:id])
    site_manager_or_owner_required
  end

end

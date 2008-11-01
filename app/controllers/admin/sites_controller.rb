# -*- coding: iso-8859-2 -*-
class Admin::SitesController < Admin::AdminBaseController
  # GET /admin_sites
  # GET /admin_sites.xml
  def index
    @sites = Site.find(:all, :order => 'brand, name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /admin_sites/1
  # GET /admin_sites/1.xml
  def show
    @site = Site.find(params[:id])

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
      format.xml  { render :xml => @admin_site }
    end
  end

  # GET /admin_sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /admin_sites
  # POST /admin_sites.xml
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        format.html { redirect_to(admin_site_path(@site)) }
        format.xml  { render :xml => @site, :status => :created, :location => admin_site_path(@site) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_sites/1
  # PUT /admin_sites/1.xml
  def update
    @site = Site.find(params[:id])

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
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to(admin_sites_path) }
      format.xml  { head :ok }
    end
  end

  # Dispaly screen for layouting photos.
  # It allows to assign photos to gallerias, change order, add separators
  def layout
    @site = Site.find(params[:id])
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
    @site = Site.find(params[:id])
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

  # Move gallelry if already exists
  def layout_add_gallery_photo
    @site = Site.find(params[:id])
    @gallery = @site.galleries.find(params[:gallery_id])
    @photo = @site.photos.find(params[:photo_id].split('_')[-1])
    photo_position = params[:photo_position].to_i

    if @gallery and @photo
     @gallery.add_photo(@photo, photo_position)
    end
      
    respond_to do |format|
      format.html { layout_gallery_photos_partial }
      format.xml  { head :ok  }
    end
  end

  def layout_remove_gallery_photo
    @site = Site.find(params[:id])
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
        gallery_photo_ids = gallery.galleries_photos.map{|gp| gp.photo_id}
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

end

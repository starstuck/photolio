class Admin::PhotosController < ApplicationController

  before_filter(:get_site)

  # GET /admin_photos
  # GET /admin_photos.xml
  def index
    @photos = @site.photos.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photos }
    end
  end

  # GET /admin_photos/1
  # GET /admin_photos/1.xml
  def show
    @photo = @site.photos.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /admin_photos/new
  # GET /admin_photos/new.xml
  def new
    @photo = @site.photos.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /admin_photos/1/edit
  def edit
    @photo = @site.photos.find(params[:id])
  end

  # POST /admin_photos
  # POST /admin_photos.xml
  def create
    @photo = @site.photos.build(params[:photo])

    respond_to do |format|
      if @photo.save
        flash[:notice] = 'Admin::Photo was successfully created.'
        format.html { redirect_to admin_site_photo_path(@site, @photo) }
        format.xml  { render :xml => @photo, :status => :created, :location => admin_site_photo_path(@site, @photo) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_photos/1
  # PUT /admin_photos/1.xml
  def update
    @photo = @site.photos.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        flash[:notice] = 'Admin::Photo was successfully updated.'
        format.html { redirect_to admin_site_photo_path(@site, @photo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_photos/1
  # DELETE /admin_photos/1.xml
  def destroy
    @photo = @site.photos.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_photos_url(@site)) }
      format.xml  { head :ok }
    end
  end

  protected
  
  def get_site
    @site = Site.find(params[:site_id])
  end
end

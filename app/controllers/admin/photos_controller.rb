class Admin::PhotosController < Admin::BaseController

  before_filter(:setup_site_context)

  # GET /admin_photos
  # GET /admin_photos.xml
  def index
    @photos = @site.photos

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photos }
    end
  end

  # GET /admin_photos/1
  # GET /admin_photos/1.xml
  def show
    @photo = @site.owned_photos.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /admin_photos/new
  # GET /admin_photos/new.xml
  def new
    @photo = @site.owned_photos.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  def include
    @photos = @site.find_available_external_photos :order => 'file_name'

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photos }
    end     
  end

  # GET /admin_photos/1/edit
  def edit
    @photo = @site.owned_photos.find(params[:id])
  end

  # POST /admin_photos
  # POST /admin_photos.xml
  def create
    keywords_data = nil
    participants_data = nil

    if params[:photo].key? 'keywords'
      keywords_data = params[:photo].delete('keywords')
    end

    if params[:photo].key? 'participants'
      participants_data = params[:photo].delete('participants')
    end

    @photo = @site.owned_photos.build(params[:photo])
    saved = @photo.save

    if saved
      @photo.update_keywords(keywords_data.values) if keywords_data
      @photo.update_participants(participants_data.values) if participants_data
    end

    respond_to do |format|
      if saved
        flash[:notice] = 'Photo was successfully created.'
        format.html { redirect_to admin_site_photos_path(@site) }
        format.xml  { render :xml => @photo, :status => :created, :location => admin_site_photos_path(@site) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add_externals
    included = []
    share_pool_site_ids = @site.share_pool.map{ |s| s.id }
    for photo_id in params[:ids]
      photo = Photo.find(photo_id)
      if share_pool_site_ids.include? photo.site_id
        included << photo
        @site.external_photos << photo
      end
    end

    respond_to do |format|
      if not included.empty?
        flash[:notice] = '#{included.size} photos were succesfully included in current site.'
        format.html { redirect_to admin_site_photos_path(@site) }
        format.xml  { render :xml => nil, :status => :created, :location => admin_site_photos_path(@site) }
      else
        format.html { render :action => "include" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def remove_external
    @photo = @site.external_photos.find(params[:id])
    @site.external_photos.delete(@photo)

    respond_to do |format|
      format.html { redirect_to(admin_site_photos_path(@site)) }
      format.xml  { head :ok }
    end
  end

  # PUT /admin_photos/1
  # PUT /admin_photos/1.xml
  def update
    @photo = @site.owned_photos.find(params[:id])

    if params[:photo].key? 'keywords'
      keywords_data = params[:photo].delete('keywords')
      @photo.update_keywords(keywords_data.values)
    end

    if params[:photo].key? 'participants'
      participants_data = params[:photo].delete('participants')
      @photo.update_participants(participants_data.values)
    end

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        flash[:notice] = 'Photo was successfully updated.'
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
    @photo = @site.owned_photos.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_photos_path(@site)) }
      format.xml  { head :ok }
    end
  end

end

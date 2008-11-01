class Admin::PhotoKeywordsController < Admin::AdminBaseController
 
  before_filter(:get_photo)

  # GET /photo_keywords
  # GET /photo_keywords.xml
  def index
    @photo_keywords = @photo.photo_keywords.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_keywords }
    end
  end

  # GET /photo_keywords/1
  # GET /photo_keywords/1.xml
  def show
    @photo_keyword = @photo.photo_keywords.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo_keyword }
    end
  end

  # GET /photo_keywords/new
  # GET /photo_keywords/new.xml
  def new
    @photo_keyword = @photo.photo_keywords.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo_keyword }
    end
  end

  # GET /photo_keywords/1/edit
  def edit
    @photo_keyword = @photo.photo_keywords.find(params[:id])
  end

  # POST /photo_keywords
  # POST /photo_keywords.xml
  def create
    @photo_keyword = @photo.photo_keywords.build(params[:photo_keyword])

    respond_to do |format|
      if @photo_keyword.save
        flash[:notice] = 'PhotoKeyword was successfully created.'
        format.html { redirect_to admin_site_photo_keywords_path(@photo) }
        format.xml  { render :xml => @photo_keyword, :status => :created, :location => admin_site_photo_keyword(@site, @photo, @photo_keyword) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photo_keywords/1
  # PUT /photo_keywords/1.xml
  def update
    @photo_keyword = @photo.photo_keywords.find(params[:id])

    respond_to do |format|
      if @photo_keyword.update_attributes(params[:photo_keyword])
        flash[:notice] = 'PhotoKeyword was successfully updated.'
        format.html { redirect_to admin_site_photo_keywords_path(@site, @photo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_keywords/1
  # DELETE /photo_keywords/1.xml
  def destroy
    @photo_keyword = @photo.photo_keywords.find(params[:id])
    @photo_keyword.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_photo_keywords_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def get_photo
    @site = Site.find(params[:site_id])
    @photo = @site.photos.find(params[:photo_id])
  end
end

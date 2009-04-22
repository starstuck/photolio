class Admin::GalleriesController < Admin::AdminBaseController

  before_filter(:setup_site_context)
  
  # GET /admin_galleries
  # GET /admin_galleries.xml
  def index
    @galleries = @site.galleries.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @galleries }
    end
  end

  # GET /admin_galleries/1
  # GET /admin_galleries/1.xml
  def show
    @gallery = @site.galleries.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @gallery }
    end
  end

  # GET /admin_galleries/new
  # GET /admin_galleries/new.xml
  def new
    @gallery = @site.galleries.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @gallery }
    end
  end

  # GET /admin_galleries/1/edit
  def edit
    @gallery = @site.galleries.find(params[:id])
  end

  # POST /admin_galleries
  # POST /admin_galleries.xml
  def create
    @gallery = @site.galleries.build(params[:gallery])

    respond_to do |format|
      if @gallery.save
        flash[:notice] = 'Gallery was successfully created.'
        format.html { redirect_to admin_site_galleries_path(@site) }
        format.xml  { render :xml => @gallery, :status => :created, :location => admin_site_galleries_path(@site) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_galleries/1
  # PUT /admin_galleries/1.xml
  def update
    @gallery = @site.galleries.find(params[:id])

    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        flash[:notice] = 'Gallery was successfully updated.'
        format.html { redirect_to admin_site_galleries_path(@site) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_galleries/1
  # DELETE /admin_galleries/1.xml
  def destroy
    @gallery = @site.galleries.find(params[:id])
    @gallery.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_galleries_path(@site)) }
      format.xml  { head :ok }
    end
  end
end

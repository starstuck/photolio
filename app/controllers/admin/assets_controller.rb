class Admin::AssetsController < Admin::AdminBaseController

  before_filter(:setup_site_context)

  def index
    @assets = @site.assets.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assets }
    end
  end

  def show
    @asset = @site.assets.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @asset }
    end
  end

  def new
    @asset = @site.assets.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asset }
    end
  end

  def edit
    @asset = @site.assets.find(params[:id])
  end

  def create
    @asset = @site.assets.build(params[:asset])

    respond_to do |format|
      if @asset.save
        flash[:notice] = 'Asset was successfully created.'
        format.html { redirect_to admin_site_asset_path(@site, @asset) }
        format.xml  { render :xml => @asset, :status => :created, :location => admin_site_asset_path(@site, @asset) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @asset = @site.assets.find(params[:id])

    respond_to do |format|
      if @asset.update_attributes(params[:photo])
        flash[:notice] = 'Asset was successfully updated.'
        format.html { redirect_to admin_site_asset_path(@site, @asset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @asset = @site.assets.find(params[:id])
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_assets_path(@site)) }
      format.xml  { head :ok }
    end
  end

end
  

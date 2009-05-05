class Admin::AttachmentsController < Admin::AdminBaseController

  before_filter(:setup_site_context)

  def index
    @attachments = @site.attachments.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attachments }
    end
  end

  def show
    @attachment = @site.attachments.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @attachment }
    end
  end

  def new
    @attachment = @site.attachments.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attachment }
    end
  end

  def edit
    @attachment = @site.attachments.find(params[:id])
  end

  def create
    @attachment = @site.attachments.build(params[:attachment])

    respond_to do |format|
      if @attachment.save
        flash[:notice] = 'Attachment was successfully created.'
        format.html { redirect_to admin_site_attachment_path(@site, @attachment) }
        format.xml  { render :xml => @attachment, :status => :created, :location => admin_site_attachment_path(@site, @attachment) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @attachment = @site.attachments.find(params[:id])

    respond_to do |format|
      if @attachment.update_attributes(params[:photo])
        flash[:notice] = 'Attachment was successfully updated.'
        format.html { redirect_to admin_site_attachment_path(@site, @attachment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @attachment = @site.attachments.find(params[:id])
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_attachments_path(@site)) }
      format.xml  { head :ok }
    end
  end

end
  

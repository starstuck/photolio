class Admin::TopicsController < Admin::BaseController

  before_filter(:setup_site_context)
  
  # GET /admin_topics
  # GET /admin_topics.xml
  def index
    @topics = @site.topics.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /admin_topics/1
  # GET /admin_topics/1.xml
  def show
    @topic = @site.topics.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /admin_topics/new
  # GET /admin_topics/new.xml
  def new
    @topic = @site.topics.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /admin_topics/1/edit
  def edit
    @topic = @site.topics.find(params[:id])
  end

  # POST /admin_topics
  # POST /admin_topics.xml
  def create
    @topic = @site.topics.new(params[:topic])

    respond_to do |format|
      if @topic.save
        flash[:notice] = 'Topic was successfully created.'
        format.html { redirect_to admin_site_topic_path(@site, @topic) }
        format.xml  { render :xml => @topic, :status => :created, :location => admin_site_topic_path(@site, @topic) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_topics/1
  # PUT /admin_topics/1.xml
  def update
    @topic = @site.topics.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to admin_site_topic_path(@site, @topic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_topics/1
  # DELETE /admin_topics/1.xml
  def destroy
    @topic = @site.topics.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_topics_url(@site)) }
      format.xml  { head :ok }
    end
  end

end

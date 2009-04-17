class Site::TopicController < Site::SiteBaseController
  
  before_filter :setup_topic_context

  def show
    respond_to do |format|
      format.html { render :template => (template_for :topic), :layout => layout }
      format.parthtml { render :template => (template_for :topic), :layout => false }
    end
  end

  private
  
  def setup_topic_context
    @topic = @site.topics.find( :first, :conditions => { 'name' => params[:topic_name] } )
  end

end

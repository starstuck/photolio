class Site::TopicController < Site::BaseController
  
  before_filter :setup_topic_context

  private
  
  def setup_topic_context
    @topic = @site.topics.find( :first, :conditions => { 'name' => params[:topic_name] } )
  end

end

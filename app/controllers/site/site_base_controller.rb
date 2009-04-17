class Site::SiteBaseController < ApplicationController

  before_filter :setup_site_context

  protected

  def setup_site_context
    @site = Site.find( :first, :conditions => { 'name' => params[:site_name] } )
  end

  def template_for name
    "#{@site.name}/#{name}"
  end

  def layout
    @site.name
  end


  
end

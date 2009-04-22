class Admin::AdminBaseController < ApplicationController
  include AuthenticatedSystem
  
  before_filter :login_required

  # Default admin master page redirect
  # If user has only one site, and cannot manage users, he will be redirected 
  # directly to his onlly site
  def index
    if current_user.has_multisite_view
      redirect_to admin_sites_path, :status => 307
    elsif current_user.sites.count > 0
      redirect_to admin_site_path(current_user.sites[0]), :status => 307
    else
      flash[:notice] = 'You have logged in succesfully, but your account is not assigned to any site. Please conteact your administrator.'
      redirect_to new_session_path
    end
  end

  protected

  def new_session_path
    new_admin_session_path
  end
  
  def setup_site_context
    @site = Site.find(params[:site_id])
    test_user_allowed_access_site
  end

  def test_user_allowed_access_site
    if not current_user.has_site_role(@site)
      flash[:notice] = 'You have insufficient permissions to manage site: ' + @site.name
      access_denied
    end
  end

end

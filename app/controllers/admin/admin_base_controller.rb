class Admin::AdminBaseController < ApplicationController

  def index
    redirect_to admin_sites_path, :status => 307
  end

end

class Admin::UsersController < Admin::AdminBaseController

  before_filter :user_manager_required, :only => [:index, :new, :create, :destroy, :reset_password]
  before_filter :user_manager_or_owner_required, :only => [:show, :edit, :update]
  before_filter :owner_required, :only => [:change_password]

  def index
    @users = User.find(:all, :order => 'login')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    populate_roles_selection
    populate_sites_selection
  end
  
  def change_password
  end

  def reset_password
    @user = User.find(params[:id])
    password = gen_password
    user_data = {
      :password => password,
      :password_confirmation => password,
      :must_change_password => true
    }

    respond_to do |format|
      if @user.update_attributes(user_data)
        flash[:notice] = "User password has been reseted to: " + password
        format.html { redirect_to admin_users_path }
        format.xml { render :xml => @user, :status => :created, :location => admin_users_path }
      else
        flash[:notice] = "Unable to reset password: " + @user.errors
        format.html { redirect_to admin_users_path }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

  end

  def create
    @user = User.new(params[:user])

    @user.must_change_password = true
    password = gen_password
    @user.password = password
    @user.password_confirmation = password
    
    respond_to do |format|
      if @user.save
        flash[:notice] = "User was succesfully created with password: " + password
        format.html { redirect_to admin_users_path }
        format.xml { render :xml => @user, :status => :created, :location => admin_users_path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      failed = false
 
      if params[:user_roles_empty] or params[:user_roles]
        if not current_user.has_role('users_manager')
          failed = true
          flash[:error] = 'Only user manager can update roles'
        end
      end

      if params[:user_roles_empty] or params[:user_roles]
        if not current_user.has_role('users_manager')
          failed = true
          flash[:error] = 'Only owner can change ts password'
        end
      end
        
      if params[:user_sites_empty] or params[:user_sites]
        if current_user.has_role('users_manager')
          if params[:user_sites]
            params[:user][:sites] = Site.find(params[:user_sites])
          else
            params[:user][:sites] = []
          end
        else
          failed = true
          flash[:error] = 'Only user manager can update sites'
        end
      end

      if params[:user_update_action] == 'change_password'
        action_name = 'change_password'
      else
        action_name = 'new' 
      end

      if not failed and @user.update_attributes(params[:user])
        if (params[:user_roles_empty] or params[:user_roles]) and current_user.has_role('users_manager')
          @user.update_roles(params[:user_roles])
        end
        if action_name == 'change_password'
          flash[:notice] = "Password was succesfully updated."
          @user.must_change_password = false
          @user.save
          format.html { redirect_back_or_default(admin_root_path) }
          format.xml { head :ok }
        else
          flash[:notice] = "User data was succesfully updated."
          format.html { redirect_to admin_user_path }
          format.xml { head :ok }
        end
      else
        if action_name == 'new'
          populate_roles_selection
          populate_sites_selection
        end
        format.html { render action_name }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user  = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(admin_users_path) }
      format.xml  { head :ok }
    end
  end

  private

  def user_manager_required
    if not current_user.has_role('users_manager')
      insufficient_priv
    end
  end
  
  def user_manager_or_owner_required
    @user  = User.find(params[:id])
    if not (current_user == @user or current_user.has_role('users_manager'))
      insufficient_priv
    end
  end

  def owner_required
    @user  = User.find(params[:id])
    if not (current_user == @user)
      insufficient_priv
    end
  end

  def insufficient_priv
    flash[:notice] = 'You have insufficient permissions to access requested page.'
    access_denied
  end

  def gen_password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(8) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def populate_roles_selection
    @all_user_roles = [['Users manager', 'users_manager']]
    @selected_user_roles = @user.user_roles.find(:all).collect{|x| x.name}
  end

  def update_user_with_roles_selection
    roles_to_delete = []
    for role_name in params[:users_roles]
      if not @user.user_roels.exist? :name => role_name


        @user_roles.create(:name => role_name)


      end
    end
        
  end

  def populate_sites_selection
    @all_user_sites = Site.find(:all).collect{|s| [s.name, s.id]}
    @selected_user_sites = @user.sites.find(:all).collect{|s| s.id}
  end

end

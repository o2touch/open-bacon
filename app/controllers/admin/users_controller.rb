class Admin::UsersController < Admin::AdminController

  def index

    filter_options = %w[mobile]

    @users = User.all if params[:filter].nil? || filter_options.include?(params[:filter])

    if params[:filter] == "mobile"
      @user_ids = MobileDevice.all.map {|md| md.user_id}
      @users = User.find(@user_ids)
    end

  end
  
  def show
    
    begin
      Float(params[:id])
      id = true
    rescue
      id = false
    end


    if id
      @user = User.find(params[:id]) 
    else
      @user = User.find(:first, :conditions => [ "lower(username) = ?", params[:id].downcase ])
    end
  end

  # Display Active Users
  def active
    @numInvites = 0
    @activeUsers = []
    @allOrganisers = []

    User.all.each do |user|
      # Active?
      active = false
      user.events_created.each do |event|
        active = true if(event.teamsheet_entries.size >= 5)
      end
      
      if(user.events_created.size > 0 || user.teams_as_organiser.size > 0)
        @allOrganisers << user
      end
      
      if active
        @activeUsers << user
        @numInvites += user.users_invited.size
      end
    end

    render 'active'
  end
  
  # DELETE admin/users
  def destroy
    
    begin
      Float(params[:id])
      id = true
    rescue
      id = false
    end

    if id
      @user = User.find(params[:id]) 
    else
      @user = User.find(:first, :conditions => [ "lower(username) = ?", params[:id].downcase ])
    end

    @user.nuke unless @user.nil?
    
    redirect_to admin_index_index_path, :notice => "User NUKED!"
  end
  
end
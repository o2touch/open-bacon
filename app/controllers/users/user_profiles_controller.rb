class Users::UserProfilesController < ApplicationController  

  include VanityUsernames
  include EventJsonHelper

  helper  ApplicationHelper

  # Render private page if access is denied
  rescue_from CanCan::AccessDenied, :with => :no_permissions

  def show
    check_demo = false

    # Two paths route to this action short_profile and long_profile

    if params[:id] # long_profile path has been used

      if params[:id].to_s =~ /^[0-9]+/
        @user = User.find(params[:id]) # when users do not have a username
      else
        @user = User.find_by_username!(params[:id]) # catch old links to profiles
      end

      # if user has username, we should be using the new path
      return head(:moved_permanently, :location => user_profile_path(@user)) if user_has_username?(@user)

    elsif params[:username] then # short_profile path has been used
      @user = User.find_by_username!(params[:username])
    end

    authorize! :read, @user

    # Check if at right domain
    change_domain, host = change_domain_for_tenanted_model?(@user)
    redirect_to user_url(@user, host: host) and return if change_domain

    # tenant info
    @tenant = LandLord.new(@user).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "user" }).html_safe 

    # this is getting out of hand... Use perms?? TS
    # Only display children if parent is looking
    @user_children = @user.children if !@user.nil? && !current_user.nil? && @user.parent? && @user.id == current_user.id
    @user_children ||= []
      
    @profile = @user.profile
    
     user_cache_key = ""
    if (!current_or_guest_user.nil?)
      user_cache_key = current_or_guest_user.rabl_cache_key
    end

    @team_mates_cache_key = "TeamMatesFragment/#{user_cache_key}/UserProfile/#{@user.rabl_cache_key}"
    @events_cache_key = "EventsFragment/#{user_cache_key}/UserProfile/#{@user.rabl_cache_key}"

    x = time do
      @activity_items_json = [].to_json
      feed_cache_key = @user.feed_cache_key(:profile, nil, nil, 20, nil)

      logger.info "BF Cache - Feed cache_key is #{feed_cache_key}"
      
      @activity_items_json = fetch_from_cache "#{feed_cache_key}" do 
        Rabl.render(@user.get_mobile_feed(:profile, nil, nil, 20, nil)[0].select { |activity_item| can? :view, activity_item }, "api/v1/activity_items/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new,  :handlers => [:rabl]).html_safe
      end
    end
    logger.debug "BF Cache - Activity Items" + (x.to_s)

    x = time do #4-5s (7 events) 
      @future_events_json = Rails.cache.fetch @events_cache_key + "/future"do 
        json_collection(@user.future_events, current_or_guest_user).html_safe
      end

      @past_events_json = Rails.cache.fetch @events_cache_key + "/past/20" do 
        json_collection(@user.past_events(true).last(20), current_or_guest_user).html_safe
      end
    end
    logger.debug "BF Cache - Events" + (x.to_s)

    if @user.nil?
      raise ActiveRecord::RecordNotFound
    end

    # change to not show users' contact details
    if can? :read_private_details, @user
      @profile_user_template = "api/v1/users/show"
      @profile_parent_template = "api/v1/users/index"
    else
      @profile_user_template = "api/v1/users/show_reduced_squad"
      @profile_parent_template = "api/v1/users/index_reduced_squad"
    end
    #@profile_user_template = "api/v1/users/show_reduced"
    #@profile_parent_template = "api/v1/users/index_reduced"

    @global_application_context = BFFakeContext.new

    @profile_user_json = Rabl.render(@user, @profile_user_template, view_path: 'app/views', formats: [:json], :scope => @global_application_context, handlers: [:rabl])

    @user_children_json = Rabl.render(@user_children, "api/v1/users/index_micro", view_path: 'app/views', formats: [:json], scope: @global_application_context, handers: [:rabl])

    if @user.junior?
      @profile_user_parent_json = Rabl.render(@user.parents, @profile_parent_template, view_path: 'app/views', formats: [:json], scope: @global_application_context, handers: [:rabl])
    end

    if !current_user.nil?
      @user_json = Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @teams_json = Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
    end
    
    set_meta_tags :title => "#{@user.name.titleize}"
    set_meta_tags :description => "View #{@user.name.titleize} sports profile on Mitoo."

    respond_to do |format|
      format.html { }
    end
    
  end
  
  def upload_profile_picture 
    user = User.find(params[:id])
    authorize! :update, user
    user.create_profile_if_not_exist
    
    user.profile.profile_picture = params["user-profile-picture"]
    user.profile.save!
    
    render json: user.profile
  end


  # Show private profile template
  def no_permissions

    check_demo = false    

    @profile_user_json = Rabl.render(@user, 'api/v1/users/show_reduced_private', view_path: 'app/views', formats: [:json], :scope => @global_application_context, handlers: [:rabl])
    @profile_user_meta_json = {
      "numUserEvents" => @user.past_events.count,
      "numUserFriends" => @user.friends.count,
      "numUserTeams" => @user.teams.count
    }.to_json

    if !current_user.nil?
      @user_json = Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @teams_json = Rabl.render(current_user.teams, "api/v1/teams/index_reduced_gamecard", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
    end

    set_meta_tags :title => "#{@user.name.titleize}"
    set_meta_tags :description => "View #{@user.name.titleize} sports profile on Mitoo."

    render 'no_permissions'

  end
end
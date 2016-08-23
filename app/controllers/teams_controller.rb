class TeamsController < ApplicationController
  include EventJsonHelper
  include TeamUrlHelper
  include DynamicStylesheetHelper

  skip_authorization_check :only => [:index]

  # Render private page if access is denied
  rescue_from CanCan::AccessDenied, :with => :no_permissions


  def index
    @limit = params[:limit].nil? ? 25000 : params[:limit].to_i
    @page = params[:page].nil? ? 1 : params[:page].to_i
    @offset = (@page - 1) * @limit

    @team_urls = []
    
    batch_size = 512
    ids = Team.order('created_at DESC').limit(@limit).offset(@offset).pluck(:id)
    ids.each_slice(batch_size) do |chunk|
      Team.find(chunk, :order => "field(id, #{chunk.join(',')})").each do |team|
        @team_urls << default_team_path(team, :only_path => false)
      end
    end

    render :handlers => [:builder]
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    
    # /teams/1
    if !params[:id].nil?
      @team = Team.find(params[:id]) 
      @division = @team.divisions.first
    end

    # Old FAFT Route is passed
    if !params[:faft_team_id].nil? && !params[:faft_ds_id].nil?
      
      @division = DivisionSeason.find_by_faft_id(params[:faft_ds_id])
      redirect_to '/search?q=' + params[:team_slug] and return if @division.nil?

      @team = @division.teams.find_by_faft_id(params[:faft_team_id])
      @team = Team.find_by_faft_id(params[:faft_team_id]) if @team.nil?

      head(:moved_permanently, location: default_team_path(@team)) and return
    end

    # Find team by league, division, team slug
    if !params[:league_slug].nil? && !params[:division_slug].nil? && !params[:team_slug].nil?
      @league = League.find_by_slug(params[:league_slug])
      redirect_to '/search?q=' + params[:team_slug] and return if @league.nil?

      @divisions = @league.divisions
      @division = @divisions.select{ |ds| !ds.nil? && ds.slug == params[:division_slug] }.first #should only be one
      redirect_to '/search?q=' + params[:team_slug] and return if @division.nil?

      @team = @division.teams.find_by_slug(params[:team_slug])
      redirect_to '/search?q=' + params[:team_slug] and return if @team.nil?
    end

    # Redirect tenanted teams to the right domain
    # - This check should be performed as soon as it can be
    change_domain, host = change_domain_for_tenanted_model?(@team)
    redirect_to team_url(@team, host: host) and return if change_domain

    authorize! :read, @team

    user_cache_key = ""
    user_cache_key = current_or_guest_user.rabl_cache_key if (!current_or_guest_user.nil?)

    @user = current_or_guest_user
    @events_cache_key = "EventsFragment/#{user_cache_key}/TeamProfile/#{@team.cache_key}/#{@team.events_last_updated_at.utc.to_s(:number)}"

    # tenant info
    @tenant = LandLord.new(@team).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "team" }).html_safe 

    # Show/hide page elements
    @show_download_app_marketing = !@team.is_o2_touch_team?
    @show_results_section = !@team.is_o2_touch_team?

    x = time do
      @activity_items_json = [].to_json
      feed_cache_key = @team.feed_cache_key(:profile, nil, nil, 20, nil)

      logger.info "BF Cache - Feed cache_key is #{feed_cache_key}"
      
      @activity_items_json = fetch_from_cache "#{feed_cache_key}" do 
        x = Rabl.render(@team.get_mobile_feed(:profile, nil, nil, 20, nil)[0], "api/v1/activity_items/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new,  :handlers => [:rabl]).html_safe 
        safe_js_string(x)
      end
    end
    logger.debug "BF Cache - Activity Items" + (x.to_s)

    x = time do #4-5s (7 events) 
      @future_events_json = Rails.cache.fetch @events_cache_key + "/future"do 
        json_collection(@team.future_events, @user).html_safe
      end

      @past_events_json = Rails.cache.fetch @events_cache_key + "/past" do 
        json_collection(@team.past_events, @user).html_safe
      end
    end
    logger.debug "BF Cache - Events" + (x.to_s)

    template = (can? :manage, @team) ? 'api/v1/users/index_reduced_squad_private' : 'api/v1/users/index_reduced_squad'
    @members_json = Rabl.render(@team.members, template, view_path: 'app/views', formats: [:json], :scope => BFFakeContext.new, locals: { :team => @team }, handlers: [:rabl]).html_safe

    # Why do we use @demo_final? Does this need to refactored out? - PR
    x = time do
      @team_json = Rails.cache.fetch "#{@team.rabl_cache_key}/#{@demo_final}" do
        Rabl.render(@team, "api/v1/teams/show", view_path: 'app/views', :locals => { :demo_final => @demo_final }, :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    logger.debug "BF Cache - Team under view" + (x.to_s)

    x = time do
      @current_user_teams_json = [].to_json
      if !current_or_guest_user.nil?
        @current_user_teams_json = Rails.cache.fetch "#{current_or_guest_user.rabl_cache_key}/CurrentTeams" do
          Rabl.render(current_or_guest_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
        end
      end
    end
    logger.debug "BF Cache - Current teams" + (x.to_s)

    x = time do
      @current_user_leagues_json = [].to_json
      if !current_user.nil?
        @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    logger.debug "BF Cache - Current leagues" + (x.to_s)

    x = time do
      @user_json = {}.to_json
      if !current_user.nil?
        @user_json = Rails.cache.fetch "#{@user.rabl_cache_key}" do
          Rabl.render(@user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
        end
      end
    end
    logger.debug "BF Cache - User" + (x.to_s)

    #Get combined user and team goals
    @goals_json = [].to_json
    if @team and @user
      combined_goals = @team.goals.get_items.merge(@user.goals.get_items) 
      combined_goals_json_array = combined_goals.map do |key, goal_checklist_item|
        goal_checklist_item.to_json
      end
      @goals_json = combined_goals_json_array.to_json.html_safe
    end
    
	  #Open invite link is required iff the user is an organiser. If this information is put in the json,
    #we end up with complicated rabl cacheing where a team is cached per user. Therefore the simple solution
    #as it stands is to put the information in the markup.
    @open_invite_link = @team.open_invite_link

    render "show_private"
  end

  def upload_profile_picture 
    @team = Team.find(params[:id])    
    authorize! :manage, @team
    
    @team.profile.profile_picture = params["team-profile-picture"]
    @team.profile.save!
    
    render(template: "api/v1/teams/show", formats: [:json], handlers: [:rabl])
  end

  # Show public profile template
  def no_permissions

    # TODO: Refactor this to use private team rabl template
    @team_json = Rails.cache.fetch "#{@team.rabl_cache_key}/#{@demo_final}" do
      Rabl.render(@team, "api/v1/teams/show_reduced_gamecard", view_path: 'app/views', :locals => { :demo_final => @demo_final }, :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end
    
    @user = current_user if @user.nil?

    # tenant info
    @tenant = LandLord.new(@team).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "team" }).html_safe 

    # TODO: This is duplicated in the show action above - could refactor
    @user_json = {}.to_json
    unless current_user.nil?
      @user_json = Rails.cache.fetch "#{current_user.rabl_cache_key}" do
        Rabl.render(@user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    
    @current_user_teams_json = [].to_json
    unless current_or_guest_user.nil?
      @current_user_teams_json = Rails.cache.fetch "#{current_or_guest_user.rabl_cache_key}/CurrentTeams" do
        Rabl.render(current_or_guest_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end

    @current_user_leagues_json = [].to_json
    unless current_user.nil?
      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end

    # Meta-tags
    title = (!@division.nil? && !@division.league.nil?) ? @team.name + " | " + @division.league.title : @team.name
    set_meta_tags :title => title

    return render 'show_public_restricted' unless can? :view_public_profile, @team


    ##### PUBLIC TEAM - SHOW PUBLIC PAGE #####

    # Public Meta-tags
    set_meta_tags :description => "The #{@team.name} Full Team Page. Browse upcoming games, latest results and team news here. Stay up-to-date - View the team page now!"
    set_meta_tags :keywords => %W[fixtures schedule results scores games #{@team.name}]
        
    @division = @team.divisions.first if @division.nil?

    @bf_club_teams = @team.club.teams unless @team.nil? || @team.club.nil?

    # USER FOLLOWING?
    @user_following = !current_user.nil? && @team.has_associate?(current_user)

    # USER DOWNLOADED APP?
    @current_user_has_downloaded_app = !current_user.nil? && !current_user.mobile_devices.empty?

    # ROLLOUT: DOWNLOAD THE APP LINK
    @download_the_app = current_user.nil? ? $rollout.active?(:faft_follow_team) : $rollout.active?(:faft_follow_team, current_user)

    @show_facebook_signup = false

    @division_presenter = DivisionPresenter.new(@division)
    @division_cache_prefix = @division.nil? ? "" : "division/#{@division.id}-#{@division.updated_at.to_i}/"

    if @division.nil?
      @future_fixture_events = @team.future_events
    else
      @future_fixtures = @division.fixtures.future.all.keep_if { |f| (f.home_team_id == @team.id || f.away_team_id == @team.id) }
      @future_fixture_events = @future_fixtures.map { |f| f.event_for_team(@team) }
      maximum_updated_at = @division.fixtures.future.maximum(:updated_at)
    end

    @future_events = EventsPresenter.new(@future_fixture_events).events
    @future_events_cache = @division_cache_prefix + "team/#{@team.id}/future_events/#{@future_events.size}-#{maximum_updated_at.to_i}"

    if @division.nil?
      @past_fixture_events = @team.past_events
    else
      @past_fixtures = @division.fixtures.past.all.keep_if { |f| f.home_team_id == @team.id || f.away_team_id == @team.id }
      @past_fixture_events = @past_fixtures.map { |f| f.event_for_team(@team) }
      maximum_updated_at = @division.fixtures.past.maximum(:updated_at)
    end

    @past_events = EventsPresenter.new(@past_fixture_events).events.reverse
    @past_events_cache = @division_cache_prefix + "team/#{@team.id}/past_events/#{@past_events.size}-#{maximum_updated_at.to_i}"

    # for marketing popup team dropdown
    unless @division.nil?
      @teams_json = Rabl.render(@division_presenter.teams, "api/v1/teams/show_faft_micro", view_path: 'app/views', :formats => [:json], :handlers => [:rabl]).html_safe
    end

    render 'show_public', :layout => 'app_public'
  end

end

class HomeController < ApplicationController

  # before_filter :authenticate_user!, :only => [:sign_up]
  skip_before_filter :set_locale, :set_timezone
  
  def search

    #####
    # Geo redirect
    #####

    # perform the check if logged-out or 'skip_geo=true' is not set in the url
    # check_geo = (current_user.nil? || params[:skip_geo].nil? == true) ? true : false

    # if check_geo
    if false # do not redirect to old US mitoo site.
      # We want to redirect users to US site if they are in the US
      location_info = GeoIP.new("#{Rails.root}/db/GeoIP.dat").country(request.remote_ip)
      location = location_info.country_code2

      if location=="US"
        redirect_to "http://" and return
      end
    end


    set_meta_tags :title => "Sports Games & Results for Teams & Leagues", :description => "The Mobile Sports Network for players, parents, teams, clubs, leagues, sports associations and Governing Bodies. Find your team, club or league now!"
    set_meta_tags :keywords => %W[Football Fixtures Results Table Standings Games Schedules Leagues Players Teams Fooball Mitoo Fooball.mitoo Soccer Organise team Club Website League Website Team Website Mobile Apps iPhone Android Organise team organize team management manager captain contact sms messageboard Mitoo availability management who-can-play group messaging software governing bodies sports associations crm cricket rugby hockey ice hockey]

    @user_json = {}.to_json
    if !current_user.nil?
      @user_json = Rails.cache.fetch "#{current_user.rabl_cache_key}" do
        Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end

    @current_user_teams_json = [].to_json
    if !current_user.nil?
      @current_user_teams_json = Rails.cache.fetch "#{current_user.rabl_cache_key}/CurrentTeams" do
        Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    
    @current_user_leagues_json = [].to_json
    if !current_user.nil?
      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end
    
    @query = params[:q] if !params[:q].nil?

    # Jack's PLT optimisations
    @disable_facebook = true
    @disable_gmaps = true
    @body_class = "search-page"

    # tenant info
    @tenant = LandLord.mitoo_tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "home" }).html_safe 

    render 'search', :layout => 'app_public'
  end
    
  # Sitemaps
  def sitemap
    @arUsers = User.all
    @arTeams = Team.all
     
    headers["Last-Modified"] = @arUsers[0].updated_at.httpdate

    render :handlers => [:builder]
  end
end
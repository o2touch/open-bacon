class Unclaimed::LeagueProfilesController < ApplicationController

  def index
    @leagues = FaFullTime::FaftLeague.all
    render :handlers => [:builder]
  end

  def show

    tmpLeague = League.find_by_slug(params[:league_slug])

    raise FaFullTime::RecordNotFound if tmpLeague.nil?

    @league = tmpLeague

    # tenant info
    @tenant = LandLord.new(@league).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "league" }).html_safe 

    # @league.divisions = FaFullTime::FaftDivision.find_all_in_league(@league.id)

    # current user and their teams/leagues (for nav)
    @user_json = {}.to_json
    if !current_user.nil?
      @user_json = Rails.cache.fetch "#{current_user.rabl_cache_key}" do
        Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    @current_user_teams_json = [].to_json
    if !current_or_guest_user.nil?
      @current_user_teams_json = Rails.cache.fetch "#{current_or_guest_user.rabl_cache_key}/CurrentTeams" do
        Rabl.render(current_or_guest_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    @current_user_leagues_json = [].to_json
    if !current_user.nil?
      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end

    set_meta_tags :title => @league.title + "games & results"
    set_meta_tags :description => "Get the latest #{@league.title} scores, team news and game information on Mitoo. View Now!"
    set_meta_tags :keywords => %W[fixtures league table schedule results scores games #{@league.title}]
  
    render "unclaimed_league_page", :layout => 'app_public'
  
  rescue FaFullTime::RecordNotFound

    logger = Logger.new("#{Rails.root}/log/faft_request_logger.log")
    logger.error("#{Time.now}\tRecordNotFound\t#{params[:league_slug]}")

    redirect_to "/search?q=" + params[:league_slug]
  end

end
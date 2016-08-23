class DivisionSeasonsController < ApplicationController

  include DivisionUrlHelper

  def index
    limit = params[:limit].nil? ? 25000 : params[:limit].to_i
    page = params[:page].nil? ? 1 : params[:page].to_i
    offset = (page - 1) * limit

    @division_urls = []
    
    batch_size = 512
    ids = Division.order('created_at DESC').limit(limit).offset(offset).pluck(:id)
    ids.each_slice(batch_size) do |chunk|
      Division.find(chunk, :order => "field(id, #{chunk.join(',')})").each do |division|
        @division_urls << default_division_path(division, :only_path => false)
      end
    end

    render :handlers => [:builder]
  end

  def show

    if !params[:division_slug].nil? && !params[:league_slug].nil?
      divisions = DivisionSeason.joins(:league).where(slug: params[:division_slug], leagues: { slug: params[:league_slug]})
      @division =divisions.first
    else
      @division = DivisionSeason.find(params[:id])
    end

    # Something is wrong if this happens
    if @division.nil?
      redirect_to '/search?q=' + params[:league_slug] and return
    end

    # tenant info
    @tenant = LandLord.new(@division).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "division" }).html_safe 

    @other_divisions = []
    @other_divisions = @division.league.divisions unless @division.league.nil?

    @division_presenter = DivisionPresenter.new(@division)

    @teams_json = Rabl.render(@division.teams, "api/v1/teams/show_faft_micro", view_path: 'app/views', :formats => [:json], :handlers => [:rabl]).html_safe

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

    @division_formatted_fixtures = @division.future_fixtures.inject({}) do |x, fixture| 
      unless fixture.bftime.time.nil? || fixture.bftime.time.is_a?(Integer)
        group_by = fixture.bftime.time.strftime("%Y-%m-%d")
        x[group_by] = [] if x[group_by].nil?
        x[group_by] << fixture 
      end
      x
    end

    @division_formatted_results = @division.past_fixtures.reverse.inject({}) do |x, fixture| 
      unless fixture.bftime.time.nil? || fixture.bftime.time.is_a?(Integer)
        group_by = fixture.bftime.time.strftime("%Y-%m-%d")
        x[group_by] = [] if x[group_by].nil?
        x[group_by] << fixture 
      end
      x
    end

    set_meta_tags :title => @division.title
    set_meta_tags :description => "League table, upcoming Fixtures, recent results and the latest information about #{@division.title}"
    set_meta_tags :keywords => %W[fixtures league table schedule results scores games #{@division.title}]

    @current_user_has_downloaded_app = (!current_user.nil? && !current_user.mobile_devices.empty?)

    if !params[:iframe].nil?
      render 'show_iframe', :layout => 'iframe'
    else
      render 'show', :layout => 'app_public'
    end
  end

end
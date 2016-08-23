class LeaguesController < ApplicationController

  def index
    limit = params[:limit].nil? ? 25000 : params[:limit].to_i
    page = params[:page].nil? ? 1 : params[:page].to_i
    offset = (page - 1) * limit

    @league_urls = []
    
    batch_size = 512
    ids = League.order('created_at DESC').limit(limit).offset(offset).pluck(:id)
    ids.each_slice(batch_size) do |chunk|
      League.find(chunk, :order => "field(id, #{chunk.join(',')})").each do |league|
        @league_urls << league_path(league, :only_path => false)
      end
    end

    render :handlers => [:builder]
  end


  # 
  def show
    # ship them off to the slug if they entered an id.
    @league = League.find(params[:id]) if params.has_key? :id
    # ship them off to the new url if they entered /league/:slug
    @league = League.find_by_slug(params[:league_slug]) if params.has_key? :league_slug
    # send them back to here, but with the right url
    head(:moved_permanently, location: league_path(@league)) and return unless @league.nil?

    @league = League.find_by_slug(params[:slug]) if params[:slug]
    raise ActiveRecord::RecordNotFound.new("not found") if @league.nil?

    authorize! :read, @league

    @league_json = Rabl.render(@league, "api/v1/leagues/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe

    # tenant info
    @tenant = LandLord.new(@league).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "league" }).html_safe 

    # Generate all user for the current user
    @user_json = {}.to_json
    @current_user_leagues_json = [].to_json
    @current_user_teams_json = [].to_json
    if !current_user.nil?
      @user_json = Rails.cache.fetch "#{current_user.rabl_cache_key}" do
        Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end

      @current_user_teams_json = Rails.cache.fetch "#{current_or_guest_user.rabl_cache_key}/CurrentTeams" do
        Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end

      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end

    # if they can make updates to the league, give them the admin template
    if can? :update, @league
      render 'private_show'

    # else give them the public one.
    else
      # Use a presenter for display logic
      @league = LeaguePresenter.new(@league)

      # grab scraped specific ting...
      @contacts = ScrapedContact.where(org_type: 'League', org_id: @league.id) if @league.display_claim_actions?

      @display_officers = !@contacts.nil? && !@contacts.empty?

      set_meta_tags :title => @league.title + " games & results"
      set_meta_tags :description => "Get the latest #{@league.title} scores, team news and game information on Mitoo. View Now!"
      set_meta_tags :keywords => %W[fixtures league table schedule results scores games #{@league.title}]
    
      render 'public_show', layout: 'app_public'
    end
  end

  def upload_image
    @league = League.find(params[:id])
    authorize! :update, League

    @league.logo = params["logo"] if params.has_key? "logo"
    @league.cover_image = params["cover_image"] if params.has_key? "cover_image"

    render template: "api/v1/leagues/show", formats: [:json], handlers: [:rabl]
  end
end

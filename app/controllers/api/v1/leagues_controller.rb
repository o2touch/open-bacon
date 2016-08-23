class Api::V1::LeaguesController < Api::V1::ApplicationController
	include LocationHelper

	skip_before_filter :authenticate_user!, only: [:show]	
	skip_authorization_check only: [:index]

	# currently this is only for o2 touch, but will be expanded
	def create
		t = LandLord.o2_touch_tenant
		authorize! :create_tenanted_league, t

		# this is shit
		sport = SportsEnum::RUGBY if t.id == TenantEnum::O2_TOUCH_ID

		loc = process_location_json(params[:league][:location])

		@league = League.create({
			title: params[:league][:title],
			colour1: params[:league][:colour1] || t.colour_1,
			colour2: params[:league][:colour2] || t.colour_2,
			time_zone: params[:league][:time_zone] || current_user.time_zone,
			sport: params[:league][:sport] || sport
		})
		@league.location = loc

		@league.tenant = t
		@league.configurable_set_parent(t)
		@league.save!

		@league.add_organiser(current_user)

    render template: "api/v1/leagues/show", formats: [:json], handlers: [:rabl], status: :created
	end

	def update
		@league = League.find(params[:id])
		authorize! :update, @league

		lps = params[:league]

		@league.title = lps[:title] if lps.has_key? :title
		@league.colour1 = lps[:colour1] if lps.has_key? :colour1
		@league.colour2 = lps[:colour2] if lps.has_key? :colour2
		@league.time_zone = lps[:time_zone] if lps.has_key? :time_zone
		@league.sport = lps[:sport] if lps.has_key? :sport

		loc = process_location_json lps[:location]
		@league.location = loc if lps.has_key? :location

		@league.save!

    render template: "api/v1/leagues/show", formats: [:json], handlers: [:rabl], status: :ok
	end

	def index
		if params.has_key? :user_id
			user = User.find_by_id(params[:user_id])
			raise InvalidParameter.new("No such user") if user.nil?
		end

		user ||= current_user
		@leagues = user.leagues_through_teams

		# remove divisions that the user doesn't have a team in
		if params.has_key? :filter_divisions
			divisions = user.teams.map{ |t| t.divisions }.flatten.compact.uniq

			@leagues.each do |league|
				league.division_seasons.reject!{ |div| !divisions.include? div } # do not save, just for display
			end
		end

		respond_with @leagues
	end

	def show
		@league = League.find(params[:id])
		authorize! :read, @league

		respond_with @league
	end
end
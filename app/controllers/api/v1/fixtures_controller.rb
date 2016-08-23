class Api::V1::FixturesController < Api::V1::ApplicationController
	include LocationHelper

	skip_before_filter :authenticate_user!, only: [:show]
	skip_authorization_check only: [:index]

	def index
		@division = DivisionSeason.find_by_id(params[:division_id])
		raise InvalidParameter.new("No such division") if @division.nil?

		if params[:when].nil?
      @fixtures = @division.fixtures
    elsif params[:when] == "future"
      @fixtures = @division.future_fixtures
    elsif params[:when] == "past"
      @fixtures = @division.past_fixtures
    else
      raise InvalidParameter.new, "when is invalid"
    end
		
		respond_with @fixtures
	end

	def show
		@fixture = Fixture.find(params[:id])
		authorize! :read, @fixture

		respond_with @fixture
	end

	def create
		@division = DivisionSeason.find(params[:api_v1_division_id])
		authorize! :manage, @division

		tenant = LandLord.new(@division).tenant

		fxp = params[:fixture]

		# so that it 422s instead of 404ing
		@home_team = Team.find_by_id(fxp[:home_team_id]) 
		@away_team = Team.find_by_id(fxp[:away_team_id]) 
		raise InvalidParameter.new("No such home team") if !fxp[:home_team_id].nil? && @home_team.nil?
		raise InvalidParameter.new("No such away team") if !fxp[:away_team_id].nil? && @away_team.nil?

		@fixture = @division.fixtures.build({
			title: fxp[:title],
			status: fxp[:status] || EventStatusEnum::NORMAL,
			time_zone: fxp[:time_zone] || @division.league.time_zone,
			time_tbc: fxp[:time_tbc] || false,
		})
		@fixture.time_local = fxp[:time_local]
		@fixture.home_team = @home_team
		@fixture.away_team = @away_team
		@fixture.location = process_location_json(fxp[:location])
		@fixture.tenant = tenant
		@fixture.save!

		# set edits on the div
		@division.update_attributes!({edit_mode: 1})
		@division.touch

		# give the fixture back showing what changed
		@fixture.show_edits!

		render 'show', formats: [:json], status: :ok
	end

	def update
		@fixture = Fixture.find(params[:id])
		authorize! :update, @fixture

		fxp = params[:fixture]
		raise InvalidParameter.new("No fixture data provided") if fxp.nil?

		# so that it 422s instead of 404ing
		@home_team = Team.find_by_id(fxp[:home_team_id])
		@away_team = Team.find_by_id(fxp[:away_team_id]) 
		raise InvalidParameter.new("No such home team") if !fxp[:home_team_id].nil? && @home_team.nil?
		raise InvalidParameter.new("No such away team") if !fxp[:away_team_id].nil? && @away_team.nil?

		# make sure it can be explicitly set to nil
    location = process_location_json(fxp[:location]) if fxp.has_key?(:location)
    location = @fixture.location unless fxp.has_key?(:location) 

		@fixture.time_tbc = fxp[:time_tbc] if fxp.has_key? :time_tbc
		@fixture.title = fxp[:title] if fxp.has_key? :title
  	@fixture.status = fxp[:status] if fxp.has_key? :status
  	@fixture.time_zone = fxp[:time_zone] unless fxp[:time_zone].blank?
		@fixture.time_local = fxp[:time_local] unless fxp[:time_local].blank?
		@fixture.home_team = @home_team if fxp.has_key? :home_team_id
		@fixture.away_team = @away_team if fxp.has_key? :away_team_id
		@fixture.location = location
		@fixture.save!

		# set edits on the div
		@fixture.division_season.update_attributes!({edit_mode: 1})
		@fixture.division_season.touch

		# give the fixture back showing what changed
		@fixture.show_edits!

  	render 'show', formats: [:json], status: :ok
	end

	def clear_edits
		@fixture = Fixture.find(params[:id])
		authorize! :update, @fixture

		@fixture.clear_edits!

		head :ok
	end

	def destroy
		@fixture = Fixture.find(params[:id])
		authorize! :destroy, @fixture

		raise InvalidParameter.new("fixture not deletable") unless @fixture.is_deletable?

		@fixture.destroy

		head :no_content
	end
end

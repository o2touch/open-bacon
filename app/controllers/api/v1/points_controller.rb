class Api::V1::PointsController < Api::V1::ApplicationController
	include StandingsHelper

	def create
		@fixture = Fixture.find(params[:api_v1_fixture_id])
		authorize! :update, @fixture

		raise InvalidParameter.new("results not tracked for division") unless !@fixture.division.nil? && @fixture.division.track_results?
		raise InvalidParameter.new("points already exist for fixture") unless @fixture.points.nil?

		home_points = hash_values_to_ints(params[:points][:home_points])
		away_points = hash_values_to_ints(params[:points][:away_points])
		raise InvalidParameter.new("points must be integers") if home_points.nil? || away_points.nil?

		@points = @fixture.create_points!({
			home_points: home_points,
			away_points: away_points,
			strategy: PointsStrategyEnum::MANUAL
		})
		@points.fixture = @fixture # fucks tests if I don't do this...
		@fixture.save!
		@fixture.division_season.touch

		render 'show', formats: [:json], status: :ok
	end


	def update
		@points = Points.find(params[:id])
		authorize! :update, @points

		away_points = hash_values_to_ints(params[:points][:away_points])
		home_points = hash_values_to_ints(params[:points][:home_points])
		raise InvalidParameter.new("points must be numeric") if home_points.nil? || away_points.nil?

		@points.update_attributes!({
			home_points: home_points,
			away_points: away_points,
			strategy: PointsStrategyEnum::MANUAL
		})
		@points.fixture.division_season.touch

		render 'show', formats: [:json], status: :ok
	end

end
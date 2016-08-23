class Api::V1::ResultsController < Api::V1::ApplicationController

	def create
		@fixture = Fixture.find(params[:api_v1_fixture_id])
		authorize! :update, @fixture

		raise InvalidParameter.new("No result data provided") if params[:result].nil?
		raise InvalidParameter.new("Fixture already has a score") unless @fixture.result.nil?
		raise InvalidParameter.new("Standings not tracked for division") unless !@fixture.division_season.nil? && @fixture.division_season.track_results?

		# allowing following two lines to error if they're fucked as
		# we need to know about it. Validation of scoring_system happens
		# on division, so if it does error here it's our error
		# (ie. misnamed Result subclass), so we should send 5XX. TS
		scoring = @fixture.division_season.scoring_system
		result_class = "#{scoring.capitalize}Result".constantize

		home_score = HashWithIndifferentAccess.new(params[:result][:home_score])
		away_score = HashWithIndifferentAccess.new(params[:result][:away_score])
		@result = result_class.new({
			home_score: home_score,
			away_score: away_score
		})
		@fixture.result = @result
		@result.fixture = @fixture # avoids having to do a reload
		@fixture.save!
		@result.save!
		@fixture.division_season.touch # touch standing cache

		AppEventService.create(@result, current_user, "created", { processor: 'Ns2::Processors::ResultsProcessor'} )

		render 'show', formats: [:json], status: :ok
	end

	def update
		@result = Result.find(params[:id])
		authorize! :update, @result

		raise InvalidParameter.new("No result data provided") if params[:result].nil?

		home_score = HashWithIndifferentAccess.new(params[:result][:home_score]) unless params[:result][:home_score].nil?
		away_score = HashWithIndifferentAccess.new(params[:result][:away_score]) unless params[:result][:away_score].nil?
		@result.home_score = home_score unless home_score.nil?
		@result.away_score = away_score unless away_score.nil?
		@result.save!
		@fixture.division_season.touch # touch standing cache
		
		AppEventService.create(@result, current_user, "created", { processor: 'Ns2::Processors::ResultsProcessor'} )

		render 'show', formats: [:json], status: :ok
	end
end
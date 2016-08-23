class Api::V1::PointsAdjustmentsController < Api::V1::ApplicationController
	def create
		@division = DivisionSeason.find(params[:api_v1_division_id])
		authorize! :update, @division

		# save some typeing
		attrs = params[:points_adjustment]
		raise InvalidParameter.new("attributes required") if attrs.nil?

		@team = Team.find_by_id(attrs[:team_id])
		raise InvalidParameter.new("no such team") if @team.nil?
		raise InvalidParameter.new("results not tracked for division") unless @division.track_results?

		@points_adjustment = PointsAdjustment.create!({
			division_season: @division,
			team: @team,
			adjustment: attrs[:adjustment],
			adjustment_type: attrs[:adjustment_type] || PointsAdjustmentTypeEnum::POINTS,
			desc: attrs[:desc]
		})
		@division.touch
		
		render 'show', formats: [:json], status: :ok
	end
end
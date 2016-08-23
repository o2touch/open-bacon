class Api::V1::FixedDivisionsController < Api::V1::ApplicationController

	def create
		league = League.find(params[:api_v1_league_id])
		authorize! :update, league

		@ds = nil

		ActiveRecord::Base::transaction do
			fd = league.fixed_divisions.create!({
				tenant_id: league.tenant_id,
				rank: params[:fixed_division][:rank]
			})

			start_date = parse_date(params[:fixed_division][:start_date])
			end_date = parse_date(params[:fixed_division][:end_date])

			@ds = fd.division_seasons.create!({
				title: params[:fixed_division][:title],
				age_group: params[:fixed_division][:age_group],
				# TODO: NOT THIS
				scoring_system: ScoringSystemEnum::GENERIC,
				start_date: start_date,
				end_date: end_date,
				current_season: true,
				track_results: true,
				show_standings: true,
				tenant_id: league.tenant_id
			})

			fd.current_division_season = @ds
			fd.save!
		end

		@division = @ds
		render template: "api/v1/division_seasons/show", formats: [:json], status: :created
	end

	private
	def parse_date(date)
		begin
			Date.strptime(date, '%Y-%m-%d')
		rescue
		end
		nil
	end
end
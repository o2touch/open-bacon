class Api::V1::M::HomeCardsController < Api::V1::ApplicationController
	skip_authorization_check only: [:index]

	# TODO: refactor, rabl views etc.
	def index
		user = current_user

		# get the app, that we stuck in the params, from the header
		app = MobileApp.find(params[:app_instance_id])
		# create a landlord, so we can tenant all the data
		land_lord = LandLord.new(app)	

		feed = []
		division_cards_displayed = []

		land_lord.teams(user).each do |team|

			next_event = team.future_events.find{|e| e.status = EventStatusEnum::NORMAL}
			last_event = team.past_events.last

			# Next Event/Fixture card
			if !next_event.nil?
				if !next_event.fixture.nil?
					card = FixtureCard.new(next_event.fixture)
					card.team = team
					card.type = :next_fixture
					card.header_text = "<#{team.name}> - Next game"
				else
					card = EventCard.new(next_event)
					card.type = :next_event
					card.header_text = "<#{team.name}> - Next #{next_event.game_type_string}"
				end

				feed << card.to_json
			end

			# Event/Fixture Result card
			if !last_event.nil?
				card = nil
				if !last_event.fixture.nil? && !last_event.fixture.result.nil?
					card = FixtureCard.new(last_event.fixture)
					card.type = :fixture_result
					card.team = team
					card.header_text = "<#{team.name}> - Last result"
				# Commented as for some reason nil results seems to be getting through,
				#  and not debugging, as (as of 27/05/14) we have <1k results, compared
				#  with > 650k events. TS
				# elsif last_event.fixture.nil? && !last_event.result.nil?
				# 	card = EventCard.new(last_event)
				# 	card.type = :event_result
				# 	card.header_text = "<#{team.name}> - Last result"
				end

				feed << card.to_json unless card.nil?
			end

			
			division = team.divisions.first if team.divisions.size > 0
			division_presenter = DivisionPresenter.new(division)

			# Stats card
			display_stats = (team.divisions.size > 0)
			if display_stats
				card = TeamCard.new(team)
				card.type = :team_stats
				card.header_text = "<#{team.name}> - Stats"

				card.stats[:position] = division_presenter.standings_position(team)
				card.stats[:played] = division_presenter.games_played(team)
				card.stats[:won] = division_presenter.games_won(team)
				card.stats[:form]	= division_presenter.form_guide(team)

				feed << card.to_json
			end

			# Division Results card
			if !division.nil? && division.past_fixtures.size > 0 && !division_cards_displayed.include?(division.id)
				card = DivisionCard.new(division)
				card.type = :division_results
				card.team = team
				card.header_text = "<#{division.title}> - Latest results"

				division_cards_displayed << division.id
				feed << card.to_json
			end

		end

		render json: feed
	end

end
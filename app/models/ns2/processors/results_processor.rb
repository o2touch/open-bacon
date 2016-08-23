class Ns2::Processors::ResultsProcessor < Ns2::Processors::Base
	class << self
		protected

		def created(app_event)
			datum = "result_created"
			generate_nis(app_event, datum)
		end

		def updated(app_event)
			# we don't care about these! TS
			return []

			# datum = "result_updated"
			# generate_nis(app_event, datum)
		end

		private
		def generate_nis(app_event, datum)
			result = app_event.obj
			return [] if result.nil? || result.fixture.nil?

			home_team = result.home_team
			away_team = result.away_team

			participants = [home_team, away_team].compact

			meta_data = {
				result_id: result.id,
				actor_id: app_event.subj_id,
				fixture_id: result.fixture.id,
				mailer: "ResultMailer",
				pusher: "ResultPusher"
			}

			meta_data[:league_id] = result.fixture.league.id unless result.fixture.league.nil?
			meta_data[:division_season_id] = result.fixture.division_season.id unless result.fixture.division_season.nil?

			# doing it like this, incase the fixture ain't got no division
			teams = []
			teams << participants
			teams << result.fixture.division_season.teams unless result.fixture.division_season.nil?
			teams.flatten!.uniq!

			participant_datum = datum
			division_datum = "division_#{datum}"

			nis = []
			teams.each do |team|
				meta_data[:team_id] = team.id

				# make a div datum, unless we're messaging people in the actual teams
				if participants.include? team
					datum = participant_datum 
					meta_data[:event_id] = result.fixture.home_event.id if team == home_team
					meta_data[:event_id] = result.fixture.away_event.id if team == away_team
				else
					datum = division_datum 
					meta_data[:event_id] = nil
				end

				# should we add fixtures to tenants??
				tenant = LandLord.new(team).tenant

				team.associates.each do |m|
					next if m == app_event.subj # don't email the actor
					next if m.junior? # don't email a junior

					# Let's check the general users notifications policy
					unp = UserNotificationsPolicy.new(m, tenant)
					next unless unp.should_notify?

					# Let's check the user notifications policy for this team
					next unless UserTeamNotificationPolicy.new(m, team).should_notify?(datum)

					md = meta_data.clone

					# refactor this so only the datum is in the if statment, innit! TS
					# organiser
					if team.has_organiser? m
						nis << email_ni(app_event, m, tenant, "organiser_#{datum}", md) if unp.should_email?
						nis << push_ni(app_event, m, tenant, "organiser_#{datum}", md) if unp.should_push?
					# player
					elsif team.has_player? m
						nis << email_ni(app_event, m, tenant, "player_#{datum}", md) if unp.should_email?
						nis << push_ni(app_event, m, tenant, "player_#{datum}", md) if unp.should_push?
					# parent
					elsif team.has_parent? m
						md[:junior_ids] = team.get_players_in_team(m.children.to_a).map(&:id)
						nis << email_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_email?
						nis << push_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_push?
					# follower
					else 
						nis << email_ni(app_event, m, tenant, "follower_#{datum}", md) if unp.should_email?
						nis << push_ni(app_event, m, tenant, "follower_#{datum}", md) if unp.should_push?
					end
				end
			end
			nis
		end
	end
end
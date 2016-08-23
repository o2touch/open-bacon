class Ns2::Processors::DivisionSeasonsProcessor < Ns2::Processors::Base
	class << self

		protected
		# All protected methods get called within a transaction, thus, I'm
		#   very willing for us to make loads of assumptions in the code below -
		#   if shit fucks up nothing will be created, it'll just be retried until
		#   we fix it

		# Also, each method is expected to return an array of notification items

		# does not handle juniors, and assumes orgs are players too
		def launched(app_event)
			div = app_event.obj

			nis = []
			div.teams.each do |team|
				orgs = team.organisers
				all_players = team.players
				players_only = all_players.reject{ |p| orgs.include? p }

				meta_data = {
					team_id: team.id,
					league_id: div.league.id
				}

				tenant = LandLord.new(team).tenant

				# organiser invitations
				org_datum = "organiser_division_launched"
				orgs.each do |org|
					org_meta_data = meta_data.clone
					org_meta_data[:team_invite_id] = TeamInvite.get_invite(team, org).id
					nis << email_ni(app_event, org, tenant, org_datum, org_meta_data)
				end

				# player invitations
				p_datum = "player_division_launched"
				players_only.each do |p| 
					p_meta_data = meta_data.clone
					p_meta_data[:team_invite_id] = TeamInvite.get_invite(team, p).id
					nis << email_ni(app_event, p, tenant, p_datum, p_meta_data)
				end

				# schedules
				sc_meta_data = {league_id: div.league.id, parent_app_event_id: app_event.id}
				AppEventService.create(team, app_event.subj, "schedule_created", sc_meta_data)

			end

			nis
		end

		# does not handle juniors, and assumes orgs are players too
		def published(app_event)
			div = app_event.obj

			datum = "player_schedule_updated"

			meta_data = app_event.meta_data.clone
			meta_data[:league_id] = div.league.id
			meta_data[:parent_app_event_id] = app_event.id

			div.teams.each do |team|
				next unless team.schedule_updates?
				AppEventService.create(team, app_event.subj, "schedule_updated", meta_data)
			end

			[] # we don't send no ting directly... all via AEs we create.
		end
	end

end
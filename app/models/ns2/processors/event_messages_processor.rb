class Ns2::Processors::EventMessagesProcessor < Ns2::Processors::Base
	class << self
		protected

		def created(app_event)
			message = app_event.obj
			messageable = message.messageable
			meta_data = {
				event_message_id: message.id,
				actor_id: message.user.id
			}

			datum = "message_created"

			return division_message(messageable, app_event, datum, meta_data) if messageable.is_a?(DivisionSeason)
			return team_message(messageable, app_event, datum, meta_data) if messageable.is_a?(Team)
			return event_message(messageable, app_event, datum, meta_data) if messageable.is_a?(Event)
		end

		private
		# team event_message
		def team_message(team, app_event, datum, meta_data)
			meta_data[:team_id] = team.id
			tenant = LandLord.new(team).tenant
			
			generate_nis(app_event, app_event.obj.recipient_users, tenant, team, "team_#{datum}", meta_data)
		end

		# event event_message
		def event_message(event, app_event, datum, meta_data)
			meta_data[:event_id] = event.id
			tenant = LandLord.new(event.team).tenant

			generate_nis(app_event, app_event.obj.recipient_users, tenant, event.team, "event_#{datum}", meta_data)
		end

		# division event_message
		def division_message(division, app_event, datum, meta_data)
			meta_data[:division_id] = division.id
			tenant = LandLord.new(division).tenant

			nis = []
			division.teams.each do |team|
				meta_data[:team_id] = team.id
				nis << generate_nis(app_event, team.members, tenant, team, "division_#{datum}", meta_data)
			end
			nis.flatten
		end

		def generate_nis(app_event, recipients, tenant, team, datum, meta_data)
			nis = []

			recipients.each do |m|
				next if m == app_event.subj # don't email the actor
				next if m.junior? # don't email a junior

				unp = UserNotificationsPolicy.new(m, tenant)
				next unless unp.should_notify?

				# Let's check the user notifications policy for this team
				next unless UserTeamNotificationPolicy.new(m, team).should_notify?(datum)

				md = meta_data.clone

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
					md[:junior_ids] = recipients.select{|j| m.children.include?(j) }.map(&:id)
					nis << email_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_email?
					nis << push_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_push?
				end 
				# followers don't get emailed for dis ting.
			end
			nis
		end
	end
end

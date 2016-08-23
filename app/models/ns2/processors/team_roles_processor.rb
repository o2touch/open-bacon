# Keep this processor for team roles only, create others for other types of poly roles.
class Ns2::Processors::TeamRolesProcessor < Ns2::Processors::Base
	class << self
		protected
		def created(app_event)
			role = app_event.obj.role_id
			role_user = app_event.obj.user
			team = app_event.obj.obj # rofl

			if role == PolyRole::FOLLOWER
				follower_created(app_event, team) 
			elsif role == PolyRole::PLAYER && team.tenant_id = TenantEnum::O2_TOUCH_ID
				o2_touch_player_role_created(app_event, team)
			else
				[]
			end
			# in future more role-methods here... TS
		end

		private
		def follower_created(app_event, team)
			nis = []

			user = app_event.subj
			tenant = LandLord.new(user).tenant

			meta_data = { team_id: team.id, mailer: 'TeamRoleMailer' }
			nis << email_ni(app_event, user, tenant, "follower_created", meta_data)

			# We no-longer send out full schedules...
			#   This is only called when an existing user follows a team, so not bothering
			#   to send anything right now. TS
			# meta_data[:event_ids] = Team.find(meta_data[:team_id]).future_events.map(&:id)
			# meta_data[:mailer] = "TeamMailer" # override normal mailer
			# nis << email_ni(app_event, user, "follower_schedule_created", meta_data)

			nis
		end

		# Not sure if I'm going this the best way. maybe should just build the datum
		#  to include the tenant name, and use one method here for all tenants.
		# Or, could just do it all in the template, with internationalization??
		# Or something else?
		def o2_touch_player_role_created(app_event, team)
			nis = []

			user = app_event.subj
			role = app_event.obj
			tenant = LandLord.new(team).tenant

			meta_data = {}
			meta_data[:mailer] = 'TeamRoleMailer'
			meta_data[:player_id] = role.user.id
			meta_data[:team_id] = role.obj.id
			meta_data[:event_id] = app_event.meta_data[:event_id]

			unp = UserNotificationsPolicy.new(user, tenant)
			nis << email_ni(app_event, user, tenant, "player_o2_touch_player_role_created", meta_data) if unp.can_email?

			team.organisers.each do |o|
				unp = UserNotificationsPolicy.new(o, tenant)
				next unless unp.can_email?
				nis << email_ni(app_event, o, tenant, "organiser_o2_touch_player_role_created", meta_data)
			end

			nis
		end
	end
end
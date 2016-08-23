#####
# This processor should be used for notifications todo with users joining BF
#  (as opposed to joining a team - these should be generated in the team roles processor)
##
class Ns2::Processors::UsersProcessor < Ns2::Processors::Base
	class << self
		protected

		# This should only be used when someone has been imported
		def user_imported(app_event)
			nis = []

			user = app_event.obj
			meta_data = {}

			tenant = LandLord.new(user).tenant
			unp = UserNotificationsPolicy.new(user, tenant)

			# TODO: Do not create NI's if team_invite is nil?
			if app_event.meta_data.has_key?(:team_id) && !app_event.meta_data[:team_id].nil?
				team_invite = TeamUsersService.get_user_invite(app_event.meta_data[:team_id], user)
				meta_data[:team_id] = app_event.meta_data[:team_id]
				meta_data[:team_invite_id] = team_invite.id unless team_invite.nil?
				datum = "user_imported"
			else
				datum = "user_imported_generic"
			end

			if unp.can_email?
				meta_data[:mailer] = "Ns2UserMailer" # override normal mailer
				nis << email_ni(app_event, user, tenant, datum, meta_data)
			end

			nis
		end

		# This should only be used when someone follows a team
		def follower_registered(app_event)
			nis = []

			user = app_event.obj

			tenant = LandLord.new(user).tenant
			unp = UserNotificationsPolicy.new(user, tenant)

			meta_data = { team_id: app_event.meta_data[:team_id] }

			if unp.can_email?
				meta_data[:mailer] = "Ns2UserMailer" # override normal mailer
				nis << email_ni(app_event, user, tenant, "follower_registered", meta_data)

				# removed for now. TS
				# t7 = 7.days.from_now
				# meta_data[:event_ids] = user.future_events.select{ |e| e.time < t7 }.map(&:id)
				# meta_data[:new_sign_up] = "blates"
				# meta_data[:time_until] = t7
				# meta_data[:mailer] = "ScheduledNotificationMailer" # override normal mailer
				# nis << email_ni(app_event, user, "user_weekly_event_schedule", meta_data)

			elsif unp.can_sms?
				nis << sms_ni(app_event, user, tenant, "follower_registered", meta_data)
			end

			nis
		end


		# This is used when a follower has been invited by another user
		def follower_invited(app_event)
			nis = []

			user = app_event.obj
			inviter = app_event.subj

			# TODO: Do not create NI's if team_invite is nil?
			team_invite = TeamUsersService.get_user_invite(app_event.meta_data[:team_id], user)
			meta_data = { team_id: app_event.meta_data[:team_id] }
			meta_data[:team_invite_id] = team_invite.id unless team_invite.nil?

			tenant = LandLord.new(user).tenant
			unp = UserNotificationsPolicy.new(user, tenant)

			if unp.can_email?
				meta_data[:mailer] = "Ns2UserMailer" # override normal mailer
				nis << email_ni(app_event, user, tenant, "follower_invited", meta_data)
			elsif unp.can_sms?
				nis << sms_ni(app_event, user, tenant, "follower_invited", meta_data)
			end

			nis
		end
	end
end
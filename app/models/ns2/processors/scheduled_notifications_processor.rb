class Ns2::Processors::ScheduledNotificationsProcessor < Ns2::Processors::Base
	class << self
		protected

		def weekly_event_schedule(app_event)
			nis = []
			tz = app_event.meta_data[:time_zone]

			# times before which the event has to be to get inluded in email/push respectively
			run_time = app_event.meta_data[:utc_run_time]
			t9 = run_time + 9.days - 9.hours

			User.where(time_zone: tz).find_each do |u|
				# ******** HACK FOR VOLITUDE *******
				# TODO: put this in settings for the league/teams, innit TS
				next if u.leagues_as_player.map(&:id).include? 4

				email_events = u.future_events.select{ |e| e.time < t9 }
				
				# Do not include events for teams which the user does not want to be notified
				email_events.select do |e|
					UserTeamNotificationPolicy.new(u, e.team).should_notify?("weekly_event_schedule")
				end

				next unless email_events.count > 0

				email_md = { 
					event_ids: email_events.map(&:id),
					mailer: 'ScheduledNotificationMailer',
					time_until: t9
				}

				# TODO: refacter to structure like other processors. TS
				# email the parents
				if u.junior?
					email_md[:junior_id] = u.id

					u.parents.each do |p|
						tenant = LandLord.new(p).tenant
						unp = UserNotificationsPolicy.new(p, tenant)
						return [] unless unp.should_notify?

						nis << email_ni(app_event, p, tenant, "parent_weekly_event_schedule", email_md) if unp.can_email?
					end
				# notify the user
				else
					tenant = LandLord.new(u).tenant
					unp = UserNotificationsPolicy.new(u, tenant)
					return [] unless unp.should_notify?
						
					nis << email_ni(app_event, u, tenant, "user_weekly_event_schedule", email_md) if unp.can_email?
				end
			end

			nis
		end

		def weekly_next_game(app_event)

			user = app_event.subj
			event = app_event.obj
			team = event.team
			datum = "weekly_next_game"

			tenant = LandLord.new(team).tenant

			unp = UserNotificationsPolicy.new(user, tenant)
			return [] unless unp.should_notify?

			# Let's check the user notifications policy for this team
			return [] unless UserTeamNotificationPolicy.new(user, team).should_notify?(datum)

			push_md = {
				pusher: 'ScheduledNotificationPusher',
				event_id: event.id
			}

			sms_md = {
				smser: 'ScheduledNotificationSmser',
				event_id: event.id
			}

			nis = []
			# We only want to send this via push or sms. The weekly event schedule is sent via email
			nis << push_ni(app_event, user, tenant, "member_#{datum}", push_md) if unp.should_push?
			nis << sms_ni(app_event, user, tenant, "member_#{datum}", sms_md) if unp.should_sms?

			nis
		end
	end
end
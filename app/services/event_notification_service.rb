class EventNotificationService
	class << self


		# USED
		# Called by messages controller (when email comment fails)
		# (I think email comments are broken?? TS)
		def send_comment_from_email_failure(address, in_reply_to)
			UserMailer.delay.comment_from_email_failure(address, in_reply_to)
		end

		# USED
		# called from trigger service
		# Send event reminder to user 
		def scheduled_event_reminder_triggered(user_id, event_ids)
			
			return if user_id.nil? || event_ids.nil? || event_ids.empty?

			user = User.find(user_id)
			return unless user.should_send_email?

			events = event_ids.map { |id| Event.find(id) }

			if(events.size==1)
				tse = events.first.teamsheet_entry_for_user(user)
				
				if user.junior?
					JuniorMailerService.scheduled_event_reminder_single(user, tse)
				else
					UserMailer.delay.scheduled_event_reminder_single(tse)	
				end

			else

				teamsheet_entries = events.map { |e| e.teamsheet_entry_for_user(user)}

				if user.junior?
					JuniorMailerService.scheduled_event_reminder_multiple(user, teamsheet_entries)
				else
					UserMailer.delay.scheduled_event_reminder_multiple(user, teamsheet_entries)
				end
			end
		end

		# USED
		# called from user registrations service
		# send confirmation email to user
		def invited_user_registered(user)
			UserMailer.delay.user_registered_confirmation(user)
		end
		
		# TODO: Feeds shit??
		private
		def unavailable_noise_filter?(event, user)
			team = event.team
			return false if team.nil? || team.divisions.count == 0

			#Pick first division for time being.
			if team.league_config(team.divisions.first)[LeagueConfigKeyEnum::NOTIFY_UNAVAILABLE_PLAYERS]
				return false
			end	

			return event.teamsheet_entry_for_user(user).response_status == InviteResponseEnum::UNAVAILABLE
		end

		# find a team's updated events, for the schedule.
		def updated_events(team)
			return team.future_events if team.schedule_last_sent.nil?
				
			team.future_events.select do |event|
				!event.last_edited.nil? && event.last_edited > team.schedule_last_sent
			end
		end
	end
end
class ScheduledNotificationSmser < BaseSmser

	def member_weekly_next_game(recipient_id, tenant_id, data)
		event = Event.find(data[:event_id])
    team = Team.find(data[:team_id])

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    time_str =  event.bftime.pp_sms_time
    event_title_str = event.title.nil? ? "" : "#{event.title} "

    body = "NEXT GAME: #{team.name} #{event_title_str}- #{time_str}"

    # Append text to sms
		append_body = mobile_footer_text(recipient, team)
		body += " - " + append_body if append_body.length > 0

    sms(to: to, body: body)
	end

end
class ScheduledNotificationPusher < BasePusher

	###
	# THIS IS NOT TRIGGERED BY THE PROCESSOR ANYMORE
	# Kept this around because we might want to use this in future - PR
	###
	def user_weekly_event_schedule(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		event_count = data[:event_ids].count
		return false if event_count == 0
		# TODO: remove this once we have user schedules in the app
		team_id = Event.find(data[:event_ids].first).team_id
		return NullPushNotification.new if event_count == 0

		alert = "You have #{event_count} event#{event_count > 1 ? 's' : ''} coming up this week. View more in the schedule"
		button = "View Schedule"
		extra = {
			obj_type: "team",
			obj_id: team_id,
			verb: "schedule_created" # not really, but this gets them to the right page
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end

	###
	# THIS IS NOT TRIGGERED BY THE PROCESSOR ANYMORE
	# Kept this around because we might want to use this in future - pR
	###
	# def parent_weekly_event_schedule(recipient_id, data)
	# 	devices = User.find(recipient_id).pushable_mobile_devices
	# 	junior = User.find(data[:junior_id])
	# 	event_count = data[:event_ids].count
	# 	return NullPushNotification.new if event_count == 0
	# 	# TODO: remove this once we have user schedules in the app
	# 	team_id = Event.find(data[:event_ids].first).team_id

	# 	alert = "#{junior.first_name.titleize} has #{event_count} event#{event_count > 1 ? 's' : ''} coming up this week. View more in the schedule"
	# 	button = "View Schedule"
	# 	extra = {
	# 		obj_type: "team",
	# 		obj_id: team_id,
	# 		verb: "schedule_created" # not really, but this gets them to the right page
	# 	}

	# 	push(devices: devices, alert: alert, button: button, extra: extra)
	# end

	def member_weekly_next_game(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		
		event = Event.find(data[:event_id])
		team = event.team

		time_str =  event.bftime.pp_sms_time
		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

		alert = "NEXT GAME: #{team.name} - #{event_title_str}#{time_str}"
		button = "View Schedule"
		extra = {
			obj_type: "team",
			obj_id: team.id,
			verb: "schedule_created" # not really, but this gets them to the right page
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
end
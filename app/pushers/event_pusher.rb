class EventPusher < BasePusher

	def member_event_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		event = Event.find(data[:event_id])
		return nil if event.time < Time.now.utc

		event_type_string = event.game_type_string.capitalize
		time_str =  event.bftime.pp_sms_time
		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

	    # New Game: 'vs Bluefields FC' on Wed 16th Oct at 5:00pm. View the details.
		alert = "NEW: #{event.team.name} #{event_type_string} - #{event_title_str}#{time_str}"
		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "created"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_created, :member_event_created	
	alias_method :player_event_created, :member_event_created	
	alias_method :follower_event_created, :member_event_created	

	def member_event_postponed(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		event = Event.find(data[:event_id])
		diff_map = data[:diff_map]

		event_type_string = event.game_type_string.capitalize
		time_str =  event.bftime.pp_sms_time
		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

	    # Game Postponed: 'vs Bluefields FC' on Wed 16th Oct has been postponed
	  alert = "POSTPONED: #{event.team.name} #{event_type_string} - #{event_title_str}#{time_str} has been postponed"
		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "postponed"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_postponed, :member_event_postponed	
	alias_method :player_event_postponed, :member_event_postponed	
	alias_method :follower_event_postponed, :member_event_postponed	

	def member_event_rescheduled(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		event = Event.find(data[:event_id])
		diff_map = data[:diff_map]

		event_type_string = event.game_type_string.capitalize
		
		# This appears to use :diff_map which is not passed in as metadata on a NI item - PR
		# Then time_str is used as if it should be the 
		# time_str = BFTime.new(diff_map[:time][0].utc, event.time_zone, event.time_tbc).pp_sms_time
		time_str = event.bftime.pp_sms_time

		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

	    # Game Rescheduled: 'vs Bluefields FC' on Wed 16th Oct has been rescheduled
	    alert = "RESCHEDULED: #{event.team.name} #{event_type_string} - #{event_title_str}has been rescheduled for #{time_str}"

		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "rescheduled"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_rescheduled, :member_event_rescheduled	
	alias_method :player_event_rescheduled, :member_event_rescheduled	
	alias_method :follower_event_rescheduled, :member_event_rescheduled	

	def member_event_activated(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)

		event = Event.find(data[:event_id])

		event_type_string = event.game_type_string.capitalize
		time_str =  event.bftime.pp_sms_time
		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

		alert = "ITS BACK ON: #{event.team.name} #{event_type_string} - #{event_title_str}is back on for #{time_str}"

		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "activated"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_activated, :member_event_activated	
	alias_method :player_event_activated, :member_event_activated	
	alias_method :follower_event_activated, :member_event_activated

	def member_event_cancelled(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		event = Event.find(data[:event_id])

		event_type_string = event.game_type_string.capitalize
		time_str =  event.bftime.pp_sms_time
		
		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "
    
    alert = "CANCELLED: #{event.team.name} #{event_type_string} - #{event_title_str}#{time_str} has been cancelled"
		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "cancelled"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_cancelled, :member_event_cancelled	
	alias_method :player_event_cancelled, :member_event_cancelled	
	alias_method :follower_event_cancelled, :member_event_cancelled

	def member_event_updated(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		event = Event.find(data[:event_id])

		event_type_string = event.game_type_string
		time_str =  event.bftime.pp_sms_time
		event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

		alert = "UPDATED: Details about #{event.team.name} #{event_type_string} - #{event_title_str}#{time_str} have changed"

		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "updated"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_updated, :member_event_updated	
	alias_method :player_event_updated, :member_event_updated	
	alias_method :follower_event_updated, :member_event_updated

	def player_or_parent_event_invite_reminder(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		recipient = User.find(recipient_id)
		devices = recipient.pushable_mobile_devices(tenant)
		event = Event.find(data[:event_id])

		event_type_string = event.game_type_string
    I18n.locale = recipient.locale unless recipient.locale.nil?
		date_time = event.bftime.pp_sms_time

		name = "is #{User.find(data[:junior_id]).name.titleize}" if data.has_key? :junior_ids
		name = "are you" unless data.has_key? :junior_id

		alert = "REMINDER: There's a #{event.team.name} #{event_type_string} on #{date_time}, #{name} #{I18n.t "general.availability.available", locale: tenant.i18n}?"

		button = "View Event"
		extra = {
			"obj_type" => "event",
			"obj_id" => data[:event_id],
			"verb" => "reminder"
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_invite_reminder, :player_or_parent_event_invite_reminder	
	alias_method :player_event_invite_reminder, :player_or_parent_event_invite_reminder	
end
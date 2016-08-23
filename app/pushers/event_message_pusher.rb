class EventMessagePusher < BasePusher

	def member_event_message_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		message = EventMessage.find(data[:event_message_id])
		poster = User.find(data[:actor_id])
		event = message.messageable

		from_str = poster.name
		message_str = message.text

		alert = "#{from_str}: #{message_str} (on #{event.game_type_string}: #{event.title})"
		button = "View Message"
		extra = {
			obj_type: "message",
			obj_id: data[:event_message_id],
			verb: "created",
			activity_item_id: message.activity_item.id
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_event_message_created, :member_event_message_created
	alias_method :player_event_message_created, :member_event_message_created
	alias_method :organiser_event_message_created, :member_event_message_created

	def member_team_message_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		message = EventMessage.find(data[:event_message_id])
		poster = User.find(data[:actor_id])
		team = message.messageable

		from_str = poster.name
		message_str = message.text

		alert = "#{from_str}: #{message_str} (#{team.name})"
		button = "View Message"
		extra = {
			obj_type: "message",
			obj_id: data[:event_message_id],
			verb: "created",
			activity_item_id: message.activity_item.id
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_team_message_created, :member_team_message_created
	alias_method :player_team_message_created, :member_team_message_created
	alias_method :organiser_team_message_created, :member_team_message_created

	def member_division_message_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		message = EventMessage.find(data[:event_message_id])
		poster = User.find(data[:actor_id])
		division = message.messageable
		
		from_str = poster.name
		message_str = message.text

		alert = "#{from_str}: #{message_str} (#{division.league.title})"
		button = "View Message"
		extra = {
			obj_type: "message",
			obj_id: data[:event_message_id],
			verb: "created",
			activity_item_id: message.activity_item.id
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :parent_division_message_created, :member_division_message_created
	alias_method :player_division_message_created, :member_division_message_created
	alias_method :organiser_division_message_created, :member_division_message_created

end

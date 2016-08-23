class TeamPusher < BasePusher
	def member_schedule_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		team = Team.find(data[:team_id])

		alert = "#{team.name}'s schedule has just been published!"
		button = "View Schedule"
		extra = {
			obj_type: "team",
			obj_id: data[:team_id],
			verb: "schedule_created",
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :organiser_schedule_created, :member_schedule_created
	alias_method :player_schedule_created, :member_schedule_created
	alias_method :parent_schedule_created, :member_schedule_created
	alias_method :follower_schedule_created, :member_schedule_created

	def member_schedule_updated(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		team = Team.find(data[:team_id])

		alert = "#{team.name}'s schedule has been updated"
		button = "View Schedule"
		extra = {
			obj_type: "team",
			obj_id: data[:team_id],
			verb: "schedule_updated",
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :organiser_schedule_updated, :member_schedule_updated
	alias_method :player_schedule_updated, :member_schedule_updated
	alias_method :parent_schedule_updated, :member_schedule_updated
	alias_method :follower_schedule_updated, :member_schedule_updated
end
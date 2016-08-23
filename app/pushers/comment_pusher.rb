class CommentPusher < BasePusher

	def comment_created(recipient_id, tenant_id, data)
  	tenant = Tenant.find(tenant_id)
  	devices = User.find(recipient_id).pushable_mobile_devices(tenant)
  	poster = User.find(data[:actor_id])
  	comment = ActivityItemComment.find(data[:comment_id])
  	activity_item = ActivityItem.find(data[:activity_item_id])

  	alert = "Reply from #{poster.name}: #{comment.text}"
  	button = "View Comment"
  	extra = {
  		obj_type: "comment",
  		obj_id: comment.id,
  		verb: "created",
  		activity_item_id: activity_item.id
  	}

    push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :message_comment_created, :comment_created
	alias_method :invite_response_comment_created, :comment_created
end
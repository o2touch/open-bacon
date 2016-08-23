# Created as there are some existing NIs that are looking for this
#  we can delete this as soon as they are processed. TS
class SoccerResultPusher < BasePusher
	def member_result_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		result = Result.find(data[:result_id])
		team = Team.find(data[:team_id])

		score = "#{result.home_final_score_str}:#{result.away_final_score_str}"
		if result.home_final_score_str.to_i < result.away_final_score_str.to_i
			score = "#{result.away_final_score_str}:#{result.home_final_score_str}"
		end

		opposition = result.home_team == team ? result.away_team.name : result.home_team.name 

		alert = "#{team.name} WON #{score} vs #{opposition}" if result.won? team
		alert = "#{team.name} LOST #{score} vs #{opposition}" if result.lost? team
		alert = "#{team.name} DREW #{score} vs #{opposition}" if result.draw?

		button = "View Result"

		extra = {
			obj_type: "event", # actually result, but no result page...
			obj_id: data[:event_id],
			verb: "updated" # actually created
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :organiser_result_created, :member_result_created
	alias_method :player_result_created, :member_result_created
	alias_method :parent_result_created, :member_result_created
	alias_method :follower_result_created, :member_result_created

	def member_result_updated(recipient_id, tenant_id, data)
		#CRUMP - TURNED THIS OFF
		# tenant = Tenant.find(tenant_id)
		# devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		# result = Result.find(data[:result_id])
		# team = Team.find(data[:team_id])

		# alert = "#{team.name} won #{result.home_final_score_str}:#{result.away_final_score_str}" if result.won? team
		# alert = "#{team.name} lost #{result.home_final_score_str}:#{result.away_final_score_str}" if result.lost? team
		# alert = "#{team.name} drew #{result.home_final_score_str}:#{result.away_final_score_str}" if result.draw?

		# button = "View Result"
		# extra = {
		# 	obj_type: "event", # actually result, but no result page in app
		# 	obj_id: data[:event_id],
		# 	verb: "updated",
		# }

		# push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :organiser_result_updated, :member_result_updated
	alias_method :player_result_updated, :member_result_updated
	alias_method :parent_result_updated, :member_result_updated
	alias_method :follower_result_updated, :member_result_updated
end
class ResultPusher < BasePusher
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

		alert = "Congratulations to #{team.name} for winning #{score} vs #{opposition}" if result.won? team
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

	# This is to send notifications to everyone else in the division.
	def member_division_result_created(recipient_id, tenant_id, data)
		tenant = Tenant.find(tenant_id)
		devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		result = Result.find(data[:result_id])

		score = "#{result.home_final_score_str}:#{result.away_final_score_str}"
		alert = "LEAGUE RESULT: #{result.home_team.name} #{score} #{result.away_team.name}"

		button = "View Results"

		extra = {
			obj_type: "division", 
			obj_id: data[:division_season_id],
			verb: "results_updated" 
		}

		push(devices: devices, alert: alert, button: button, extra: extra)
	end
	alias_method :organiser_division_result_created, :member_division_result_created
	alias_method :player_division_result_created, :member_division_result_created
	alias_method :parent_division_result_created, :member_division_result_created
	alias_method :follower_division_result_created, :member_division_result_created

	def member_result_updated(recipient_id, tenant_id, data)
		#CRUMP - TURNED THIS OFF
		# tenant = Tenant.find(tenant_id)
		# devices = User.find(recipient_id).pushable_mobile_devices(tenant)
		# devices = User.find(recipient_id).pushable_mobile_devices
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
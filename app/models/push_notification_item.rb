class PushNotificationItem < Ns2NotificationItem
	
	queueable worker: Ns2NotificationItemWorker, run_method: :deliver

	# nb. If this errors, it will be tried again... ie. All or nothing should fail.
	def deliver
		pusher = self.meta_data[:pusher].constantize
		push = pusher.send(self.datum.to_sym, user_id, tenant_id, meta_data)

		return false if push.nil? || push.is_a?(NullPushNotification)

		transaction_data = push.deliver
		self.meta_data[:transaction_data] = transaction_data
		self.save

		# For some reason part of the JSON we're getting back is fucked, so hacking
		#  as below for now...
		#if !transaction_data[1].has_key?(:ok) || transaction_data[1][:ok] != true
		if transaction_data[1].is_a? String
			raise "Urbanairship returned error - See NI meta_data" 
		end

		true	
	end	

	def set_medium
		self.medium = "push"
	end
end
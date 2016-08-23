class SmsNotificationItem < Ns2NotificationItem
	# ********************	
	# ***** Worker is specific to sms, so we can just have a specific queue for it,
	# ***** so 1 sms gets sent at a time, so no seg faults! TS
	# ********************	
	queueable worker: Ns2SmsNotificationItemWorker, run_method: :deliver

	# check that only one is being run at a time
	def ready?
		count = SmsNotificationItem.where(status: QueueItemStatusEnum::PROCESSING).count
		return true unless count > 1

		self.attempts += Random.rand(3.0) # add extra randomisation, to avoid race conditions
		false
	end

	# nb. If this errors, it will be tried again... ie. All or nothing should fail.
	def deliver
		smser = self.meta_data[:smser].constantize
		sms = smser.send(self.datum.to_sym, user_id, tenant_id, meta_data)

		return false if sms.nil? || sms.respond_to?(:null_sms?) # work around as rspec can't NullSms

		# ********************	
		# **** Sleep is to make sure only one sms is sent at a time
		# **** to try and avoid seg faults!
		# ********************	
		#sleep 1

		# this will throw if sms provider doesn't like it
		transaction_data = sms.deliver 
		self.meta_data[:transaction_data] = transaction_data
		self.save

		# this will throw if upstream from twilio doesn't like it
		raise "Upstream SMS provider rejected SMS" if transaction_data[:status] == "failed"

		# ********************	
		# **** Sleep is to make sure only one sms is sent at a time
		# **** to try and avoid seg faults!
		# ********************	
		#sleep 1

		true	
	end	

	def set_medium
		self.medium = "sms"
	end
end
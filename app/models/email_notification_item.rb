class EmailNotificationItem < Ns2NotificationItem
	
	queueable worker: Ns2NotificationItemWorker, run_method: :deliver

	# nb. If this errors, it will be tried again... ie. All or nothing should fail.
	def deliver
		mailer = self.meta_data[:mailer].constantize
		
		mailer.default "X-SMTPAPI" => '{"unique_args": {"notification_id":"' + self.id.to_s + '"}}' unless self.id.nil?

		mail = mailer.send(self.datum.to_sym, user_id, tenant_id, meta_data)

		# this will happen a mailer does not call mail()
		return false if mail.class.name == 'ActionMailer::Base::NullMail'

		mail.deliver
		true	
	end	

	def set_medium
		self.medium = "email"
	end
end
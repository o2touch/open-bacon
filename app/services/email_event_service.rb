class EmailEventService
	class << self
		
		# Handles SendGrid event received through web hook
		def process_event(params)

			# Email Processed
			self.processed(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp]) if params[:event]=="processed"

			# Email Dropped
			self.dropped(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp]) if params[:event]=="dropped"

			# Email Delivered
			self.delivered(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp], params[:response]) if params[:event]=="delivered"

			# Email Deferred
			self.deferred(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp]) if params[:event]=="deferred"

			# Email Bounced
			self.bounce(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp]) if params[:event]=="bounce"

			# Email Viewed Event
			self.open(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp], params[:ip], params[:useragent]) if params[:event]=="open"

			# Email Clicked Event
			self.click(params[:notification_id], params[:email], params["smtp-id"], params[:category], params[:timestamp]) if params[:event]=="click"
			
		end

		# Message received and ready to be delivered
		def processed(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("processed", email_notification_id, email, smtpid, category, timestamp)
		end

		# Invalid header, Spam content, unsubscribed address, bounced address, Spam reporting address, invalid
		def dropped(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("dropped", email_notification_id, email, smtpid, category, timestamp)
		end

		# Message has been successfully delivered to the receiving server.
		def delivered(email_notification_id, email, smtpid, category, timestamp, response)
			
			meta_data = {
				response: response
			}

			self.create_sendgrid_email_event("delivered", email_notification_id, email, smtpid, category, timestamp)
		end

		# Recipient’s email server temporarily rejected message.
		def deferred(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("deferred", email_notification_id, email, smtpid, category, timestamp)
		end

		# Receiving server could not or would not accept message.
		def bounce(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("bounce", email_notification_id, email, smtpid, category, timestamp)
		end

		# Recipient has opened the HTML message.
		def open(email_notification_id, email, smtpid, category, timestamp, ip, useragent)

			meta_data = {
				ip: ip,
				useragent: useragent
			}

			self.create_sendgrid_email_event("open", email_notification_id, email, smtpid, category, timestamp, meta_data)
		end

		# Recipient clicked on a link within the message.
		def click(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("click", email_notification_id, email, smtpid, category, timestamp)
		end

		# Recipient marked message as spam.
		def spam_report(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("spam_report", email_notification_id, email, smtpid, category, timestamp)
		end

		# Recipient clicked on messages’s subscription management link.
		def unsubscribe(email_notification_id, email, smtpid, category, timestamp)
			self.create_sendgrid_email_event("unsubscribe", email_notification_id, email, smtpid, category, timestamp)
		end
		

		def create_sendgrid_email_event(type, email_notification_id, email, smtpid, category, timestamp, meta_data=nil)
			e = SendgridEmailEvent.new
			e.event = type
			e.email_notification_id = email_notification_id
			e.email = email
			e.smtpid = smtpid
			e.category = category
			e.meta_data = meta_data
			e.event_time = Time.at(timestamp)
			e.save!
		end
	end
end
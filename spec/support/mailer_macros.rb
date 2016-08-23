require 'sidekiq/testing'

module MailerMacros
	def last_email
		ActionMailer::Base.deliveries.pop
	end

	def last_emails
		emails = ActionMailer::Base.deliveries
		reset_emails
		emails
	end

	def last_delayed_emails
		delay = Sidekiq::Extensions::DelayedMailer.jobs.size
		Sidekiq::Worker.drain_all
		sleep(0.001*delay) # Wait for threads

		last_emails
	end

	def last_delayed_email
		last_delayed_emails.pop
	end

	def reset_emails
		ActionMailer::Base.deliveries = []
	end
end

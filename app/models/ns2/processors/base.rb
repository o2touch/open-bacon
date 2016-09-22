class Ns2::Processors::Base
	class Unprocessable < StandardError; end

	class << self

		# process the activity item
		def process(app_event_id)
			app_event = AppEvent.find(app_event_id)
			return if app_event.processed?

			verb_symbol = app_event.verb.to_sym

			# raise so that we see it in new relic.
			raise Unprocessable.new("Cannot process #{app_event.verb}") unless self.respond_to? verb_symbol

			nis = []
			ActiveRecord::Base.transaction do
				nis = self.send(verb_symbol, app_event)
				raise Unprocessable.new("NS2 processor verb methods must return an array") if nis.nil?
				app_event.update_attributes!({ processed_at: Time.now })
			end

			# processed here, so that no notifications get processed if processor throws
			#  even if it has already created a notification or two...
			nis.compact.each{ |ni| ni.process } # compact for user.should_never_notify?
		end

		# simply to clean up the above methods
		def email_ni(app_event, user, tenant, datum, meta_data)
			# don't send to unsubscribed people
			return nil unless user.should_send_email?

			# set the mailer, unless it's been manually set
			# maybe move this to inside email_notification_item.rb ?? TS
			meta_data[:mailer] = "#{app_event.obj.class}Mailer" unless meta_data.has_key? :mailer

			EmailNotificationItem.create!({
			 	app_event: app_event,
				user: user,
				tenant: tenant,
				datum: datum,
				meta_data: meta_data
			}) # do not process here, so that if the processor fails later, no NIs get processed! TS
		end

		def push_ni(app_event, user, tenant, datum, meta_data)
			# # commented as we check this in the processors, though left in as this is a better place
			# #  to check (ie. a bottle neck), though not sure if we need the flexibility of doing it
			# #  in the processors... TS
			# # P.S. it would change into creating a UserNotificationPolicy, and checking from that...  
			# # return if user.should_never_notify? || !user.should_send_push_notifications?

			# # set the mailer, unless it's been manually set
			# # maybe move this to inside email_notification_item.rb ?? TS
			# meta_data[:pusher] = "#{app_event.obj.class}Pusher" unless meta_data.has_key? :pusher

			# PushNotificationItem.create!({
			# 	app_event: app_event,
			# 	user: user,
			# 	tenant: tenant,
			# 	datum: datum,
			# 	meta_data: meta_data
			# })

			# urbane airship is broken, or something. Either way, we have shit loads of
			# errors in our sidekiq logs because pushes don't get sent out.
			# now we're not going to bother trying.
			return nil
		end

		def sms_ni(app_event, user, tenant, datum, meta_data)
			# commented as we check this in the processors, though left in as this is a better place
			#  to check (ie. a bottle neck), though not sure if we need the flexibility of doing it
			#  in the processors... TS
			# P.S. it would change into creating a UserNotificationPolicy, and checking from that...  
			# return if user.should_never_notify? || !user.should_send_sms?

			# set the smser, unless it's been manually set
			# maybe move this to inside email_notification_item.rb ?? TS
			meta_data[:smser] = "#{app_event.obj.class}Smser" unless meta_data.has_key? :smser

			SmsNotificationItem.create!({
				app_event: app_event,
				user: user,
				tenant: tenant,
				datum: datum,
				meta_data: meta_data
			})
		end
	end
end
class AppEventService
	class << self
		# **** This is nice because it makes it super simple in the
		#  controller, however on the other side it seems kind of pointless
		#  to write all the repeated code, innit. Not sure best way forward. TS

		# **** Update... Just use the create method. TS

		# EVENTS
		def event_created(event, subject, meta_data)
			create(event, subject, "created", meta_data)
		end

		def event_updated(event, subject, meta_data)
			create(event, subject, "updated", meta_data)
		end

		def event_cancelled(event, subject, meta_data)
			create(event, subject, "cancelled", meta_data)
		end

		def event_activated(event, subject, meta_data)
			create(event, subject, "activated", meta_data)
		end

		def event_postponed(event, subject, meta_data)
			create(event, subject, "postponed", meta_data)
		end

		def event_rescheduled(event, subject, meta_data)
			create(event, subject, "rescheduled", meta_data)
		end

		def event_deleted(event, subject, meta_data)
			create(event, subject, "deleted", meta_data)
		end


		def create(obj, subject, verb, meta_data={})

			# Do not create AppEvents for DemoEvent objects
			return if obj.is_a? DemoEvent

			AppEvent.create!({
				obj: obj,
				subj: subject,
				verb: verb,
				meta_data: meta_data
			}).process
		end
	end
end
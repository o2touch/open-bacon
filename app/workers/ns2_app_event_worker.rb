class Ns2AppEventWorker
	include Sidekiq::Worker
	sidekiq_options queue: "ns2-app-events"

	def perform(app_event_id, processor_string)
		processor_string.constantize.process(app_event_id)
	end
end
class Ns2NotificationItemWorker
	include Sidekiq::Worker
	sidekiq_options queue: "ns2-delivery-queue"

	def perform(clazz, ni_id)
		# we already know the clazz, so don't care about it...
		Ns2NotificationItem.run(ni_id)
	end
end
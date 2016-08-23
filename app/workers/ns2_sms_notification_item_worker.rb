# ********************	
# **** This class exists to we can control how quickly (slowly) smses are sent,
# **** more than one at at time causes a segfault, so not using the normal
# **** NI worker... TS
# ********************	
class Ns2SmsNotificationItemWorker
	include Sidekiq::Worker
	sidekiq_options queue: "ns2-sms-delivery-queue"

	def perform(clazz, ni_id)
		# we already know the clazz, so don't care about it...
		Ns2NotificationItem.run(ni_id)
	end
end
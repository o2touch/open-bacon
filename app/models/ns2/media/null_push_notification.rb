class NullPushNotification
	def platforms; [] end
	def tokens; [] end
	def notification_data; {} end

	def null_notification?
		true
	end

	def self.build(datum, devices, data)
		NullPushNotification.new
	end

	def add_device(device)
		false
	end

	def set_datum(datum)
		false
	end

	def deliver
		raise "Cannot deliver a NullPushNotification"
	end
end
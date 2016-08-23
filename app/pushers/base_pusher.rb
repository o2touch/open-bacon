class BasePusher

	include PusherHelper

	def push(attrs)
		devices = attrs[:devices]

		notification_data = {}
		notification_data[:title] = attrs[:title] if attrs.has_key? :title
		notification_data[:alert] = attrs[:alert]
		notification_data[:button] = attrs[:button] if attrs.has_key? :button
		notification_data[:extra] = attrs[:extra] if attrs.has_key? :extra

		return NullPushNotification.new if devices.blank?
		return NullPushNotification.new if notification_data[:alert].blank?

		# Notification payload must be under 256 bytes
		payload_size = notification_data.to_s.bytesize

		if payload_size > 256
			reduce_by = payload_size - (256 - 3)
			max_alert_size = notification_data[:alert].to_s.bytesize - reduce_by

			# Let's shave size off of the alert
			if notification_data[:alert].encoding.name == 'UTF-8'
				new_alert = limit_bytesize_utf8(notification_data[:alert], max_alert_size)
			else
				new_alert = limit_bytesize(notification_data[:alert], max_alert_size)
			end

			notification_data[:alert] = pretty_truncate(new_alert, new_alert.size) + "..."
		end

		PushNotification.build(devices, notification_data)
	end

	class << self
		protected
		# a simplified version of the fucked up shit that allows you to call
		# instance methods as though they were class methods in ActionMailer. TS
	  def method_missing(method_name, *args)
	  	if public_instance_methods.include? method_name
	  		new.send(method_name, *args)
	  	else
	  		super
	  	end
	  end

  end
end
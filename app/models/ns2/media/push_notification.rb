class PushNotification
	def self.build(devices, notification_data)
		push = PushNotification.new
		push.set_notification_data(notification_data)
		devices.each{ |d| push.add_device(d) }
		push
	end

	def initialize
		@platforms = []
		@tokens = []
		@notification_data = {}
		@app = nil
	end

	def set_notification_data(data)
		@notification_data = data	
	end

	def add_device(device)
		@platforms << device.platform

		@tokens << { "device_token" => device.token } if device.is_ios?
		@tokens << { "apid" => device.token } if device.is_android?

		@app = device.mobile_app if @app.nil?

		return unless @app != device.mobile_app
		raise "push notifications must go to only one app type at a time (ie. mitoo, or o2_touch)" 
	end

	def data
		@notification_data
	end

	# This is all a little bit of a hack, as Dirigible only supports one mobile app per webapp,
	#  and this was easier than adding support. TS
	def deliver
		# Push notifications not currently enabled
		return [nil, nil]

		# api = Dirigible::API.new({ app_key: @app.ua_app_key, master_secret: @app.ua_master_secret} )

		# begin
		# 	pl = payload
		# 	response = api.post('/push', pl)
		# rescue => e
		# 	# it just sticks the response in here...
		# 	response = e.message
		# end

		# [pl, response]
	end

	# old_deliver
	# def old_deliver
	# 	pl = payload
	# 	response = Urbanairship.push(pl)
	# 	[pl, response]
	# end

	protected
	def payload
		raise "At least one device must be added" if @tokens.count == 0

		device_types = @platforms.uniq.map(&:downcase)

		audience = @tokens.first if @tokens.count == 1
		audience = { "or" => @tokens.uniq } if @tokens.count > 1

		notification = {}
		device_types.each do |dt|
			notification[dt] = self.send("#{dt}_notification_hash".to_sym)
		end

		payload = { 
			"audience" => audience, 
			"notification" => notification, 
			"device_types" => device_types
		}

		payload
	end

	def ios_notification_hash
		# commented as providing text for the button (action-loc-key) causes UA to break...
		# alert = {}
		# alert[:body] = @notification_data[:alert] 
		# alert["action-loc-key"] = @notification_data[:button] if @notification_data.has_key? :button

		# remove badge while we sort out a notification centre, innit.
		#hash = { badge: "+1", sound: "default"}
		hash = { sound: "default"}
		hash[:extra] = @notification_data[:extra] if @notification_data.has_key? :extra
		hash[:alert] = @notification_data[:alert] 

		hash
	end

	def android_notification_hash
		hash = {}
		hash[:alert] = @notification_data[:alert]
		hash[:extra] = @notification_data[:extra] if @notification_data.has_key? :extra

		hash
	end
end
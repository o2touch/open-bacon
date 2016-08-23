class DeviceRegistrationsService
	class << self
		# register a device as belonging to a user
		def register_device(user, device_token, device_data)
			device = MobileDevice.find_or_create_by_token(device_token)

			new_registration = device.id.nil?
			reactivation = (!device.id.nil? && !device.active?)

			device.update_attributes!({
				user: user,
				active: true,
				logged_in: true,
				platform: device_data[:platform],
				model: device_data[:model],
				os_version: device_data[:os_version],
				app_version: device_data[:app_version],
				mobile_app_id: device_data[:app_instance_id]
			})

		end

		# user has deleted the app
		def deactivate_device(device_token)
			device = MobileDevice.find_by_token(device_token)
			device.update_attributes!({ logged_in: false, active: false })
		end
 
		# user has logged out of bf
		def logout_device(device_token)
			device = MobileDevice.find_by_token(device_token)
			device.update_attributes!({ logged_in: false })
		end

	end
end
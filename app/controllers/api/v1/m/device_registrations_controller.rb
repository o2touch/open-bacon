class Api::V1::M::DeviceRegistrationsController < Api::V1::ApplicationController
	skip_authorization_check only: [:create, :destroy]

	def create
		user = current_user
		d_attrs = params[:device]
		raise InvalidParameter.new("device token is required") if d_attrs.nil?
		
		device_token = d_attrs[:token]
		raise InvalidParameter.new("device token is required") if device_token.nil?

		data = {}
		data[:platform] = d_attrs[:platform] if d_attrs.has_key? :platform
		data[:model] = d_attrs[:model] if d_attrs.has_key? :model
		data[:os_version] = d_attrs[:os_version] if d_attrs.has_key? :os_version
		data[:app_version] = d_attrs[:app_version] if d_attrs.has_key? :app_version
		data[:app_instance_id] = params[:app_instance_id]

		DeviceRegistrationsService.register_device(user, device_token, data)

		head :created
	end

	def destroy
		device_token = params[:token]
		raise InvalidParameter.new("device token is required") if device_token.nil?

		# return 404 if they don't own the device
		device = current_user.mobile_devices.select{ |d| d.token == device_token }.first
		raise ActiveRecord::RecordNotFound.new if device.nil?

		DeviceRegistrationsService.logout_device(device_token)
		head :no_content
	end
end
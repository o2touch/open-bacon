class Api::V1::Users::UserRegistrationsController < Api::V1::ApplicationController
	
	skip_before_filter :authenticate_user!, only: [:create]
	# done in the service, if required.
	skip_authorization_check only: [:create]

	# Creating a user, obvs, (or confirming on).
	# Create the motherfucker here, then the UserRegService has methods to complete
	#  whatever the other action that should be completed is.
	#  eg. follow a team/join a team/create a team/confirm account
	def create
		raise InvalidParameter.new "save_type is required" if params[:save_type].nil?
		save_type = params[:save_type]

		# for confirmation links they're automatically signed in
		@user = current_user

		raise InvalidParameter.new if @user.nil? && params[:user].nil?

		ActiveRecord::Base.transaction do
			attrs = params[:user]

			if @user.nil?
				# allow invited users to sign up, and override their existing details
				@user = User.find_by_email(attrs[:email])
				if !@user.nil?
					raise InvalidParameter.new("User exists") unless @user.has_role? RoleEnum::INVITED
				else
					@user = User.new
				end

		    country = GeographicDataUtil.new().country_from_ip(request.remote_ip)
		    time_zone = request.cookies['timezone']
	    	time_zone = TimeZoneEnum[0] if time_zone.nil?

				@user.update_attributes!({
					name: attrs[:name],
					email: attrs[:email],
					country: country,
					time_zone: time_zone,
					mobile_number: attrs[:mobile_number],
					invited_by_source: params[:save_type],
					password: attrs[:password],
					password_confirmation: attrs[:password],
					tenanted_attrs: attrs[:tenanted_attrs] || {}
				})
				@user.profile.update_attributes({
					gender: attrs[:gender],
					dob: attrs[:dob],
				})
				@user.generate_password if attrs[:password].nil?
				
				save_utm_data(@user)
			end

			# where the magic happens
			UserRegistrationsService.complete_registration(@user, save_type, params)
		end

		sign_in @user, bypass: true

		@user.ensure_authentication_token!
		render template: "api/v1/m/sessions/create", formats: [:json], status: :ok
	end
end

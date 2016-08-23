class FacebookProfileImageWorker
	include Sidekiq::Worker
	sidekiq_options queue: "facebook-profile-image"

	def perform(user_id, auth_token)
		FacebookService.fetch_user_profile_image(user_id, auth_token)
	end
end
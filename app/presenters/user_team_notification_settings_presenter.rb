class UserTeamNotificationSettingsPresenter < Draper::CollectionDecorator
  	
	def decorator_class
		UserTeamNotificationSettingPresenter
	end

	def as_hash
		hash = {}

		all_is_false = false

		# Override all settings with false if NOTIFICATIONS_ENABLED key is false
		decorated_collection.each do |s|
			all_is_false = true if s.notification_key==NotificationGroupsEnum::NOTIFICATIONS_ENABLED.to_s && s.value == false
		end

		# Generate the hash
		decorated_collection.each do |s|
			# TODO: Only show the settings that they can change
			hash[s.notification_key] = all_is_false ? false : s.value
		end

		return hash
	end
end
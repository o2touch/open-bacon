class UserTeamNotificationPolicy

	def initialize(user, team)
	    @user = user
	    @team = team

	    @settings = load_settings
	end

	def should_notify?(notification_key)
		
		# If 'all' is set and is false
    return false if @settings[NotificationGroupsEnum::NOTIFICATIONS_ENABLED] == false

		# check if has specific setting for notification
    if @settings.key? notification_key.to_sym
      return @settings[notification_key.to_sym]
    end

		# check if has specific setting for group notification belongs to
    group_key = get_group_for_notification(notification_key)
    if !group_key.nil? && @settings.key?(group_key)
      return @settings[group_key]
    end

		# Group: Use default settings
    if !group_key.nil? && NOTIFICATION_GROUP_DEFAULTS.key?(group_key)
      return NOTIFICATION_GROUP_DEFAULTS[group_key]
    end

    # Got this far, return ture
    true
	end

	private

  # Load a users settings for a team and return a settings hash  
	def load_settings
	    user_settings = UsersTeamsNotificationSetting.where(user_id: @user.id, team_id: @team.id)

      settings_hash = {}
      user_settings.each do |s|

        k = s.notification_key.to_sym
        v = s.value

        settings_hash[k] = v
      end

      settings_hash
	end

  # This will return the group key for a notification as defined in bf_system_constants.rb
  def get_group_for_notification(notification)
    NOTIFICATION_GROUPS.each do |k,v|
      return k if v.is_a?(Array) && v.include?(notification.to_sym)
    end
    nil
  end
end
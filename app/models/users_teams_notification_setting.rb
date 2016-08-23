class UsersTeamsNotificationSetting < ActiveRecord::Base
  attr_accessible :user_id, :team_id, :notification_key, :value

  def self.add_settings(user, team, keys)
		keys.each do |k,v|
      s = self.where(user_id: user.id, team_id: team.id, notification_key: k.to_sym).first_or_create!
			s.update_attributes(value: v)
		end
  end

  def self.get_all_settings(user, team)
    user_settings = self.where(user_id: user.id, team_id: team.id)
    user_settings_keys = user_settings.map { |us| us.notification_key }.uniq

    # Create the defaults
    default_settings = []
    NOTIFICATION_GROUP_DEFAULTS.clone.each do |key, value|
      next if user_settings_keys.include?(key.to_s)
      default_settings << self.new(user_id: user.id, team_id: team.id, notification_key: key.to_s, value: value)
    end

    default_settings + user_settings
  end

end
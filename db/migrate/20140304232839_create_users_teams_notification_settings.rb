class CreateUsersTeamsNotificationSettings < ActiveRecord::Migration
  def up
  	create_table :users_teams_notification_settings do |t|
	  	t.integer :user_id
	  	t.integer :team_id
	  	t.string :notification_key
	  	t.boolean :value
	  	t.timestamps
	end
  end

  def down
  	drop_table :users_teams_notification_settings
  end
end

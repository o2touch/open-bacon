FactoryGirl.define do
  sequence(:user_guid) { |n| "#{n}" }
  sequence(:team_guid) { |n| "#{n}" }
  factory :users_teams_notification_setting do |t|
  	t.user_id { generate(:user_guid) }
  	t.team_id  { generate(:team_guid) }
  	t.notification_key "message_created"
  	t.value false
  end
end
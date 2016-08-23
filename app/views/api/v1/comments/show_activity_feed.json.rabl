attributes :id, :text, :created_at

child :user do
	extends "users/show"
end

child :message => :message do
	extends "api/v1/messages/show_activity_feed"
end
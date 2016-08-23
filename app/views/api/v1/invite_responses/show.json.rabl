object @invite_response
cache "ActivityItem/#{root_object.cache_key}"

attributes :id, :response_status, :created_at

child :teamsheet_entry do
	extends "api/v1/teamsheet_entries/show_activity_feed"
end
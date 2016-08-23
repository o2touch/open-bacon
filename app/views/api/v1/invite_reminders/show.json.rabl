object @invite_reminder
cache root_object

attributes :id, :created_at

child :teamsheet_entry do
	extends "api/v1/teamsheet_entries/show_activity_feed"
end
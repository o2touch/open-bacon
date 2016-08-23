object @teamsheet_entry

if !root_object.user.nil?
	attributes :id, :user_id, :response_status, :created_at, :event_id
	child :latest_reminder => :latest_reminder do
	 	attributes :created_at
	end
	child :reminders => :reminders
	child :user do
		extends "api/v1/users/show_reduced_private"
	end
end
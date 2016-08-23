object @teamsheet_entry

if !root_object.user.nil?
	attributes :id, :user_id, :response_status, :created_at, :event_id
	attributes :checked_in, :checked_in_at
	child :latest_reminder => :latest_reminder do
	 	attributes :created_at
	end
	child :reminders => :reminders
	child :user do
		extends "api/v1/users/show_reduced"
	end
end
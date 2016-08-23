object @teamsheet_entry

if !root_object.user.nil?
	attributes :id, :user_id, :response_status
	child :user do
		extends "api/v1/users/show_reduced_activity_item"
	end
end

node :event do |teamsheet_entry|
	partial("api/v1/events/show_reduced_activity_item_mini", :object => graceful_event(teamsheet_entry))
end


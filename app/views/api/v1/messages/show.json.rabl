object @message

attributes :id, :event_id, :text, :created_at
child :user do
	extends "api/v1/users/show_reduced_activity_item"
end

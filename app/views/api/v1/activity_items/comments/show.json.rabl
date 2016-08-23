object @activity_item_comment
cache root_object

attributes :id, :text, :created_at

child :user do
	extends "api/v1/users/show_reduced_activity_item"
end
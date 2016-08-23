object @activity_item_like
cache root_object

attributes :id, :created_at, :user_id, :activity_item_id

child :user do 
	extends "api/v1/users/show_reduced_activity_item"
end
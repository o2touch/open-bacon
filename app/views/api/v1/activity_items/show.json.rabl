object @activity_item
cache "#{root_object.rabl_cache_key}"

attributes :id, :subj_type, :obj_type, :verb, :created_at, :updated_at

node :meta_data do |activity_item|
  filtered_activity_meta_data(activity_item.meta_data)
end

node :subj do |activity_item|
  partial("api/v1/users/show_reduced_activity_item", :object => activity_item.subj)
end

node :obj do |activity_item|
  case activity_item.obj_type
  when "User"
    partial("api/v1/users/show_reduced_activity_item", :object => activity_item.obj)
  when "Event"    
    partial("api/v1/events/show_reduced_activity_item", :object => graceful_activity_event(activity_item))
  when "TeamsheetEntry"
    partial("api/v1/teamsheet_entries/show_reduced_activity_item", :object => activity_item.obj)
  when "EventMessage"
    partial("api/v1/event_messages/show", :object => activity_item.obj)
  when "InviteResponse"
    partial("api/v1/invite_responses/show", :object => activity_item.obj)
  when "InviteReminder"
    partial("api/v1/invite_reminders/show", :object => activity_item.obj)
  when "EventResult"
    partial("api/v1/event_results/show", :object => activity_item.obj)
  end
end

node :likes do |activity_item|
	partial("api/v1/activity_items/likes/index", :object => activity_item.likes)
end

node :comments do |activity_item|
  partial("api/v1/activity_items/comments/index", :object => activity_item.comments)
end

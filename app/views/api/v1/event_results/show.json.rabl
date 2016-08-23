object @event_result

node :event do |event_result|
	partial("api/v1/events/show_reduced_activity_item_mini", :object => graceful_event(event_result))
end

object @teamsheet_entry

extends "api/v1/teamsheet_entries/show"

node :event do |teamsheet_entry|
  partial("api/v1/events/show_reduced_activity_item_mini", :object => graceful_event(teamsheet_entry))
end

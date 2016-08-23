extends "api/v1/messages/show"

node :messageable do |message|
  case message.messageable_type
  when "Event"
    extends "api/v1/events/show_reduced_activity_item", :view_path => 'app/views'
  end
end

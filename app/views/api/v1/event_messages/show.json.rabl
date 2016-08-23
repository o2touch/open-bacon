object @event_message
cache root_object

attributes :id, :text, :created_at, :messageable_id, :messageable_type

node :messageable do |message|
  case message.messageable_type
  when "Team"
    partial("api/v1/teams/show_micro", :object => message.messageable)
  when "Event"    
    partial("api/v1/events/show_reduced_activity_item", :object => message.messageable)#null event?
  when "DivisionSeason"
    partial("api/v1/division_seasons/show_reduced_activity_item", :object => message.messageable) 
  end
end

node :recipients do |message|
  formatted_recipients(message.meta_data['recipients'])
end

node :role_type do |message|
  message.sent_as_role_type
end

node :role_id do |message|
  message.sent_as_role_id
end

module NotificationProcessorUtil
   #TODO Refactor for performance and move into a module specific for event filtering
  def self.get_future_events_attending(events, user)
    events_attending = []
    events.each do |e|
      tse = e.teamsheet_entry_for_user(user)
      if tse.nil? == false and tse.response_status == InviteResponseEnum::AVAILABLE
        events_attending << e
      end
    end
    events_attending.compact!
    events_attending
  end
end

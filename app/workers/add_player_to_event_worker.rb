class AddPlayerToEventWorker
  include Sidekiq::Worker

  def perform(event_id, user_id, send_push_notifications)
    event = nil
    if event_id.kind_of?(Event)
      event = event_id
    else
      event = Event.find(event_id.to_i)
    end

    user = nil
    if user_id.kind_of?(User)
      user = user_id
    else
      user = User.find(user_id.to_i)
    end

    EventInvitesService.add_players(event, [user], send_push_notifications)
    true
  end
end

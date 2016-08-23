class AddPlayersToEventWorker
  include Sidekiq::Worker

  def perform(event_id, team_id, send_push_notifications)
    event = nil
    if event_id.kind_of?(Event)
      event = event_id
    else
      event = Event.find(event_id.to_i)
    end

    team = nil
    if team_id.kind_of?(Team)
      team = team_id
    else
      team = Team.find(team_id.to_i)
    end

    EventInvitesService.add_players(event, team.players, send_push_notifications)
    true
  end
end

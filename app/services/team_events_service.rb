class TeamEventsService
  def self.add(team, event, send_push_notifications=true, perform_async=true)
    event.team = team
    event.save #Why doesnt this have save! ?
    event.reload 

    return if team.team_roles.empty?

    # Add all team members to event
    if perform_async
      AddPlayersToEventWorker.perform_async(event.id, team.id, send_push_notifications)
    else
      AddPlayersToEventWorker.new.perform(event, team, send_push_notifications)
    end
  end
end
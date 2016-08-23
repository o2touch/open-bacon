class EventInvitesService
  class << self
    def add_players(event, players, send_push_notifications=true)
      tses = []

      players = players.compact
      players.reject!{ |player| event.team.parents.include?(player) } unless event.team.nil?

      players.each do |player|

        next if event.users.include? player
        tse = TeamsheetEntry.create!({user: player, event: event})
        
        tses << tse
        tse.send_push_notification("add") if send_push_notifications
      end

      tses
    end

    def remove_player(event, player)
      #This method deletes matching TeamsheetEntry records without loading object into memory first.
      #Therefore this method is very efficient. Let's keep it that way.
      TeamsheetEntry.destroy_all(["event_id = ? AND user_id = ?", event.id, player.id])
    end
  end
end

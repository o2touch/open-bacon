class TeamEnroledFourPlayers < GoalCheckListItem

  def initialize(team)
    @team = team
  end

  def complete?
    # players_id = @team.players(true).map {|x| x.id}
    # demo_players_id = @team.demo_players.map {|x| x.id}

    # (players_id - demo_players_id - [@team.founder.id]).count >= 4
    true
  end

  def notify
    name = "team-#{@team.id}-goals"
    # Pusher[name].trigger('update_goal', self.to_json, nil)
  end
end

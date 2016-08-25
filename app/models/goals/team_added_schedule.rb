class TeamAddedSchedule < GoalCheckListItem

  def initialize(team)
    @team = team
  end

  def complete?
    @team.events.size > 3
  end

  def notify
    name = "team-#{@team.id}-goals"
    # Pusher[name].trigger('update_goal', self.to_json, nil)
  end
end
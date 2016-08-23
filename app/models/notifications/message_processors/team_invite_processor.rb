class TeamInviteProcessor
  def initialize(name)
    @name = name
  end
  
  def process(notification_item)
    return false unless can_process?(notification_item)
    
    team_invite = notification_item.obj
    team = team_invite.team
    events = team.future_events
    user = team_invite.sent_to
    organiser = team_invite.sent_by
    team_invite_token = team_invite.token

    if team.has_parent?(user)
      notify_junior_team(team_invite, events)
    else
      notify_team(user, team, organiser, team_invite_token, events, notification_item)
    end
    
    true
  end

  private
  def notify_junior_team(team_invite, events)
    JuniorMailerService.parent_invited_to_team(team_invite)
    JuniorMailerService.event_schedule(team_invite, events)
  end

  def notify_team(user, team, organiser, team_invite_token, events, notification_item)
    UserMailer.delay.new_user_invited_to_team(user.id, team.id, organiser.id, team_invite_token)
    user.mailbox.deliver_message(nil, user, notification_item, UserMailer.name, 'new_user_invited_to_team')

    UserMailer.delay.event_schedule(team.founder, team, user, events) if events.size > 0
  end

  def can_process?(item)
    #Performance critical code block
    item.obj_type == TeamInvite.name and item.verb == VerbEnum::CREATED
  end
end

# class LeagueTeamInviteProcessor
#   def initialize(name)
#     @name = name
#   end

#   #TODO We dont support juniors leagues
#   def process(notification_item)
#     return false unless can_process?(notification_item)

#     team_invite = notification_item.obj
#     events = get_future_events_attending(team_invite.team.future_events, team_invite.sent_to)
#     league = notification_item.subj
#     user = team_invite.sent_to

#     LeagueMailer.delay.user_invited_to_team(team_invite.id, league.id)
#     user.mailbox.deliver_message(nil, user, notification_item, LeagueMailer.name, 'user_invited_to_team')
    
#     if events.size > 0
#       LeagueMailer.delay.event_schedule(team_invite.team.founder, team_invite.team, team_invite.sent_to, events, notification_item)
#     end

#     true
#   end

#   private
#   def can_process?(item)
#     #Performance critical code block
#     item.verb == VerbEnum::CREATED and item.obj_type == TeamInvite.name and item.subj_type == League.name
#   end

#   def get_future_events_attending(events, user) #TODO Refactor
#     NotificationProcessorUtil.get_future_events_attending(events, user)
#   end
# end

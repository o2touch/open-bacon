# class LeagueTeamRoleProcessor
#   def initialize(name)
#     @name = name
#   end

#   def process(notification_item)
#     return false unless can_process?(notification_item)
    
#     case notification_item.verb
#     when VerbEnum::CREATED
#       create_team_role(notification_item)
#     end

#     true
#   end

#   private
#   def can_process?(item)
#     #Performance critical code block
#     item.obj_type == TeamRole.name and item.verb == VerbEnum::CREATED
#   end

#   def create_team_role(notification_item)
#     case notification_item.meta_data[:role_id]
#     when PolyRole::ORGANISER
#       organiser_role_granted_to_user(notification_item)
#     end
#   end

#   def extract_team_and_user(notification_item)
#     team = Team.find(notification_item.meta_data[:team_id])
#     user = User.find(notification_item.meta_data[:user_id])
#     return team, user
#   end
  
#   def organiser_role_granted_to_user(notification_item)
#     team, user = extract_team_and_user(notification_item)
#     events = team.future_events
#     team_invite = TeamInvite.find(:first, conditions: { team_id: team.id, sent_to_id: user.id })
#     league = notification_item.subj
    
#     LeagueMailer.delay.organiser_role_granted_to_user(user.id, team.id, league.id, team_invite.token)
#     user.mailbox.deliver_message(nil, user, notification_item, UserMailer.name, 'organiser_role_granted_to_user')

#     if events.size > 0  
#       LeagueMailer.delay.event_schedule(team.founder, team, user, events, notification_item)
#     end
#   end
# end

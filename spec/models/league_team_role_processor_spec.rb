# require 'spec_helper'
# require 'sidekiq/testing'

# describe LeagueTeamRoleProcessor do
#   def build_mock_notification_item
#     meta_data =  {
#       :team_id => 1,
#       :user_id => 2
#     }

#     mock_notification_item = mock_model(NotificationItem)
#     mock_notification_item.stub(:obj_type).and_return(TeamRole.name)
#     mock_notification_item.stub(:meta_data).and_return(meta_data)
#     mock_notification_item.stub(:subj).and_return(mock_model(League))


#     mock_notification_item
#   end

#   describe 'process' do
#     it 'rejects message if the obj_type is not recognised' do
#       mock_notification_item = double('notification_item')
#       mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
#       mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)

#       LeagueTeamRoleProcessor.new('processor').process(mock_notification_item).should be_false
#     end

#     it 'rejects message if the verb is not recognised' do
#       mock_notification_item = double('notification_item')
#       mock_notification_item.stub(:verb).and_return('destroyed')
#       mock_notification_item.stub(:obj_type).and_return(TeamRole.name)

#       LeagueTeamRoleProcessor.new('processor').process(mock_notification_item).should be_false
#     end

#     it 'sends a delayed organiser role granted to the user', :sidekiq => false do
#       mock_notification_item = build_mock_notification_item
#       mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
#       mock_notification_item.meta_data[:role_id] = PolyRole::ORGANISER

#       team = mock_model(Team)
#       team.stub(:future_events).and_return([])

#       user = mock_model(User)
#       user.stub(:mailbox).and_return(Mailbox.new(nil))
#       user.mailbox.should_receive(:deliver_message).once

#       Team.stub!(:find).and_return(team)
#       User.stub!(:find).and_return(user)
#       league = mock_notification_item.subj

#       mock_team_invite = mock_model(TeamInvite)
#       mock_team_invite.stub(:token).and_return('token')
#       TeamInvite.stub!(:find).and_return(mock_team_invite)

#       LeagueMailer.should_receive(:organiser_role_granted_to_user).once.with(user.id, team.id, league.id, mock_team_invite.token)

#       LeagueTeamRoleProcessor.new('processor').process(mock_notification_item).should be_true
#     end

#     it 'sends a delayed team schedule to the user', :sidekiq => false do
#       mock_notification_item = build_mock_notification_item
#       mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
#       mock_notification_item.meta_data[:role_id] = PolyRole::ORGANISER

#       team = mock_model(Team)
#       team.stub(:future_events).and_return([])
#       team.stub(:founder).and_return(mock_model(User))
#       events = [ mock_model(Event) ]

#       user = mock_model(User)
#       user.stub(:mailbox).and_return(Mailbox.new(nil))
#       user.mailbox.should_receive(:deliver_message).once

#       Team.stub!(:find).and_return(team)
#       User.stub!(:find).and_return(user)
#       league = mock_notification_item.subj

#       mock_team_invite = mock_model(TeamInvite)
#       mock_team_invite.stub(:token).and_return('token')
#       TeamInvite.stub!(:find).and_return(mock_team_invite)

#       LeagueMailer.should_receive(:organiser_role_granted_to_user).once.with(user.id, team.id, league.id, mock_team_invite.token)
#       LeagueMailer.should_receive(:event_schedule).once.with(team.founder, team, user, events, mock_notification_item)

#       processor = LeagueTeamRoleProcessor.new('processor')
#       team.should_receive(:future_events).and_return(events)

#       processor.process(mock_notification_item).should be_true
#     end
#   end
# end

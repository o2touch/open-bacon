# require 'spec_helper'

# describe LeagueTeamInviteProcessor do
#   def build_mock_notification_item
#     mock_team = mock_model(Team)
#     mock_team.stub(:founder).and_return(mock_model(User))

#     mock_recipient = mock_model(User)
#     mock_recipient.stub(:mailbox).and_return(Mailbox.new(nil))

#     mock_team_invite = mock_model(TeamInvite)
#     mock_team_invite.stub(:team).and_return(mock_team)
#     mock_team_invite.stub(:sent_to).and_return(mock_recipient)
#     mock_team_invite.stub(:id).and_return(1)
#     mock_team_invite.stub(:token).and_return("token")

#     mock_league = mock_model(League)
#     mock_league.stub(:id).and_return(1)

#     mock_notification_item = mock_model(NotificationItem)
#     mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)
#     mock_notification_item.stub(:obj).and_return(mock_team_invite)
#     mock_notification_item.stub(:subj).and_return(mock_league)
#     mock_notification_item.stub(:subj_type).and_return(League.name)

#     mock_notification_item
#   end

#   describe 'process' do
#     it 'rejects message if the obj_type is not recognised' do
#       mock_notification_item = double('notification_item')
#       mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
#       mock_notification_item.stub(:obj_type).and_return("Object")

#       LeagueTeamRoleProcessor.new('processor').process(mock_notification_item).should be_false
#     end

#     it 'rejects message if the verb is not recognised' do
#       mock_notification_item = double('notification_item')
#       mock_notification_item.stub(:verb).and_return('destroyed')
#       mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)

#       LeagueTeamRoleProcessor.new('processor').process(mock_notification_item).should be_false
#     end

#     it 'sends a delayed user invited email to the user', :sidekiq => false do
#       mock_notification_item = build_mock_notification_item
#       mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)

#       team_invite = mock_notification_item.obj
#       team = team_invite.team
#       team.stub(:future_events).and_return([])
#       user = team_invite.sent_to
#       user.mailbox.should_receive(:deliver_message).once
#       league = mock_notification_item.subj

#       LeagueMailer.should_receive(:user_invited_to_team).once.with(team_invite.id, league.id)

#       LeagueTeamInviteProcessor.new('processor').process(mock_notification_item).should be_true
#     end

#     it 'sends a delayed team schedule to the user', :sidekiq => false do
#       mock_notification_item = build_mock_notification_item
#       mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)

#       events = [ mock_model(Event) ]
#       team_invite = mock_notification_item.obj
#       team = team_invite.team
#       team.stub(:future_events).and_return(events)
#       user = team_invite.sent_to
#       user.mailbox.should_receive(:deliver_message).once
#       league = mock_notification_item.subj

#       LeagueMailer.should_receive(:user_invited_to_team).once.with(team_invite.id, league.id)
#       LeagueMailer.should_receive(:event_schedule).once.with(team.founder, team, team_invite.sent_to, events, mock_notification_item)

#       processor = LeagueTeamInviteProcessor.new('processor')
#       processor.should_receive(:get_future_events_attending).and_return(events)

#       processor.process(mock_notification_item).should be_true
#     end
#   end
# end

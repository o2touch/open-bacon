require 'spec_helper'
require 'sidekiq/testing'

describe TeamInviteProcessor do
  def build_mock_notification_item
    founder = mock_model(User)
    invitee = mock_model(User)
    invitee.stub(:email).and_return('player@team.com')
    invitee.stub(:mailbox).and_return(Mailbox.new(nil))

    mock_team = mock_model(Team)
    mock_team.stub(:has_parent?).and_return(false)
    mock_team.stub(:founder).and_return(founder)
    mock_team.stub(:future_events).and_return([])
    
    mock_team_invite = mock_model(TeamInvite)
    mock_team_invite.stub(:team).and_return(mock_team)
    mock_team_invite.stub(:sent_to).and_return(invitee)
    mock_team_invite.stub(:sent_by).and_return(founder)
    mock_team_invite.stub(:sent_by_id).and_return(founder.id)
    mock_team_invite.stub(:token).and_return('token')
    
    mock_notification_item = mock_model(NotificationItem)
    mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
    mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)
    mock_notification_item.stub(:obj).and_return(mock_team_invite)
    mock_notification_item
  end

  describe 'process' do
    it 'rejects messages it cannot process' do
      mock_notification_item = double('notification_item')
      mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
      mock_notification_item.stub(:obj_type).and_return(PolyRole.name)

      TeamInviteProcessor.new('processor').process(mock_notification_item).should be_false
    end

    context 'adult team' do
      it 'sends a delayed team invite to the invitee', :sidekiq => false do
        mock_notification_item = build_mock_notification_item
        team_invite = mock_notification_item.obj
        team = team_invite.team
        user = team_invite.sent_to
        organiser = team_invite.sent_by
        team_invite_token = team_invite.token

        user.mailbox.should_receive(:deliver_message).once
        UserMailer.should_receive(:new_user_invited_to_team).once.with(user.id, team.id, organiser.id, team_invite_token)

        TeamInviteProcessor.new('processor').process(mock_notification_item).should be_true
      end

      it 'sends a delayed team schedule to the invitee', :sidekiq => false do
        mock_notification_item = build_mock_notification_item
        team_invite = mock_notification_item.obj
        user = team_invite.sent_to
        organiser = team_invite.sent_by
        team_invite_token = team_invite.token
        events = [ mock_model(Event), mock_model(Event) ]

        team = team_invite.team
        team.stub(:future_events).and_return(events)

        user.mailbox.should_receive(:deliver_message).once
        UserMailer.should_receive(:new_user_invited_to_team).once.with(user.id, team.id, organiser.id, team_invite_token)
        UserMailer.should_receive(:event_schedule).once.with(team.founder, team, team_invite.sent_to, events)

        TeamInviteProcessor.new('processor').process(mock_notification_item).should be_true
      end
    end

    context 'junior team' do
      it 'sends a delayed team invite to the invitee', :sidekiq => false do
        mock_notification_item = build_mock_notification_item
        team_invite = mock_notification_item.obj
        team = team_invite.team
        team.stub(:has_parent?).and_return(true)
        team.stub(:player_ids).and_return([1, 2, 3])
        child_ids = [1]
        team_invite.sent_to.stub(:child_ids).and_return(child_ids)
        parent = team_invite.sent_to

        JuniorMailer.should_receive(:parent_invited_to_team).once.with(parent.id, team.id, child_ids, team_invite.sent_by.id, team_invite.token)
        
        TeamInviteProcessor.new('processor').process(mock_notification_item).should be_true
      end

      it 'sends a delayed team schedule to the invitee', :sidekiq => false do
        mock_notification_item = build_mock_notification_item
        team_invite = mock_notification_item.obj
        events = [ mock_model(Event), mock_model(Event) ]
        event_ids = events.map(&:id)

        team = team_invite.team
        team.stub(:future_events).and_return(events)
        team.stub(:has_parent?).and_return(true)
        team.stub(:player_ids).and_return([1, 2, 3])
        child_ids = [1]
        team_invite.sent_to.stub(:child_ids).and_return(child_ids)
        parent = team_invite.sent_to

        JuniorMailer.should_receive(:parent_invited_to_team).once.with(parent.id, team.id, child_ids, team_invite.sent_by.id, team_invite.token)
        JuniorMailer.should_receive(:event_schedule).once.with(parent.id, team.id, child_ids, team_invite.sent_by.id, event_ids, team_invite.token)

        TeamInviteProcessor.new('processor').process(mock_notification_item).should be_true
      end
    end
  end
end

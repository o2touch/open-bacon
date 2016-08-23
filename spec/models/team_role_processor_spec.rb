require 'spec_helper'
require 'sidekiq/testing'

describe TeamRoleProcessor do
  def build_mock_notification_item
    meta_data =  {
      :team_id => 1,
      :user_id => 2
    }

    mock_notification_item = mock_model(NotificationItem)
    mock_notification_item.stub(:obj_type).and_return(PolyRole.name)
    mock_notification_item.stub(:meta_data).and_return(meta_data)

    mock_notification_item
  end

  describe 'process' do
    it 'rejects message if the obj_type is not recognised' do
      mock_notification_item = double('notification_item')
      mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
      mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)

      TeamRoleProcessor.new('processor').process(mock_notification_item).should be_false
    end

    it 'rejects message if the verb is not recognised' do
      mock_notification_item = double('notification_item')
      mock_notification_item.stub(:verb).and_return('edited')
      mock_notification_item.stub(:obj_type).and_return(PolyRole.name)

      TeamRoleProcessor.new('processor').process(mock_notification_item).should be_false
    end

    it 'sends a delayed user removed from team email to the user', :sidekiq => false do
      mock_notification_item = build_mock_notification_item
      mock_notification_item.stub(:verb).and_return(VerbEnum::DESTROYED)
      mock_notification_item.meta_data[:role_id] = PolyRole::PLAYER
      
      team = mock_model(Team)
      user = mock_model(User)

      Team.stub!(:find).and_return(team)
      User.stub!(:find).and_return(user)

      UserMailer.should_receive(:user_removed_from_team).once.with(user, team)

      TeamRoleProcessor.new('processor').process(mock_notification_item).should be_true
    end

    it 'sends a delayed organiser role granted to the user', :sidekiq => false do
      mock_notification_item = build_mock_notification_item
      mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
      mock_notification_item.meta_data[:role_id] = PolyRole::ORGANISER
      
      team = mock_model(Team)
      user = mock_model(User)

      Team.stub!(:find).and_return(team)
      User.stub!(:find).and_return(user)

      UserMailer.should_receive(:organiser_role_granted_to_user).once.with(user, team)

      TeamRoleProcessor.new('processor').process(mock_notification_item).should be_true
    end

    it 'sends a delayed organiser role revoked to the user', :sidekiq => false do
      mock_notification_item = build_mock_notification_item
      mock_notification_item.stub(:verb).and_return(VerbEnum::DESTROYED)
      mock_notification_item.meta_data[:role_id] = PolyRole::ORGANISER
      
      team = mock_model(Team)
      user = mock_model(User)

      Team.stub!(:find).and_return(team)
      User.stub!(:find).and_return(user)

      UserMailer.should_receive(:organiser_role_revoked_from_user).once.with(user, team)

      TeamRoleProcessor.new('processor').process(mock_notification_item).should be_true
    end
  end
end

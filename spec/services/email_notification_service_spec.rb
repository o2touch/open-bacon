require 'spec_helper'

describe EmailNotificationService do
  before(:all) do
    stop_sidekiq
    start_sidekiq
  end


  def get_mock_team_role
    mock_team = mock_model(Team)
    mock_team.stub(:id).and_return(1)
    mock_team.stub(:name).and_return("team")

    mock_user = get_mock_user
    
    mock_team_role = mock_model(PolyRole)
    mock_team_role.stub(:id).and_return(1)
    mock_team_role.stub(:obj).and_return(mock_team)
    mock_team_role.stub(:user).and_return(mock_user)
    mock_team_role.stub(:role_id).and_return(1)
    mock_team_role.stub(:created_at).and_return(Time.now)
    mock_team_role.stub(:team_id).and_return(mock_team.id)
    mock_team_role.stub(:user_id).and_return(mock_user.id)
    mock_team_role
  end

  def get_mock_team_invite
    mock_team_invite = mock_model(TeamInvite)
    mock_team_invite.stub(:id).and_return(1)
    mock_team_invite.stub(:sent_to).and_return(get_mock_user)
    mock_team_invite
  end

  def get_mock_user
    mock_user = mock_model(User)
    mock_user.stub(:id).and_return(1)
    mock_user.stub(:name).and_return("user")
    mock_user.stub(:type).and_return("User")
    mock_user
  end

  describe 'notify_created_team_role' do
    context 'user type User' do
      before :each do
        team_role = get_mock_team_role
        EmailNotificationService.notify_created_team_role(team_role, get_mock_user)
      end
      
      it 'queues a message for the message router' do
        MessageRouterWorker.jobs.size.should == 1
      end

      it 'creates a NotificationItem' do
        NotificationItem.count.should == 1
      end
    end

    context 'user type DemoUser' do
      before :each do
        team_role = get_mock_team_role
        team_role.user.stub(:type).and_return("DemoUser")
        EmailNotificationService.notify_created_team_role(team_role, get_mock_user)
      end

      it 'does not queue a message for the message router' do
        MessageRouterWorker.jobs.size.should == 0
      end

      it 'does not create a NotificationItem' do
        NotificationItem.count.should == 0
      end
    end
  end

  describe 'notify_destroyed_team_role' do
    context 'user type User' do
      before :each do
        team_role = get_mock_team_role
        EmailNotificationService.notify_destroyed_team_role(team_role, get_mock_user)
      end

      it 'queues a message for the message router' do
        MessageRouterWorker.jobs.size.should == 1
      end

      it 'creates a NotificationItem' do
        NotificationItem.count.should == 1
      end
    end

    context 'user type DemoUser' do
      before :each do
        team_role = get_mock_team_role
        team_role.user.stub(:type).and_return("DemoUser")
        EmailNotificationService.notify_destroyed_team_role(team_role, get_mock_user)
      end

      it 'does not queue a message for the message router' do
        MessageRouterWorker.jobs.size.should == 0
      end

      it 'does not create a NotificationItem' do
        NotificationItem.count.should == 0
      end
    end
  end

  describe 'notify_team_invite_created' do
    context 'user type User' do
      before :each do
        team_invite = get_mock_team_invite
        EmailNotificationService.notify_team_invite_created(team_invite, get_mock_user)
      end

      it 'queues a message for the message router' do
        MessageRouterWorker.jobs.size.should == 1
      end

      it 'creates a NotificationItem' do
        NotificationItem.count.should == 1
      end
    end

    context 'user type DemoUser' do
      before :each do
        team_invite = get_mock_team_invite
        team_invite.sent_to.stub(:type).and_return("DemoUser")
        EmailNotificationService.notify_team_invite_created(team_invite, get_mock_user)
      end

      it 'does not queue a message for the message router' do
        MessageRouterWorker.jobs.size.should == 0
      end

      it 'does not create a NotificationItem' do
        NotificationItem.count.should == 0
      end
    end
  end
end

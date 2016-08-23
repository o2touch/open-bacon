require 'spec_helper'

describe TeamMailer do
  before :each do
    @user = FactoryGirl.create :user 
    @parent = FactoryGirl.create :user
    @follower = FactoryGirl.create :user
    @junior1 = FactoryGirl.create :junior_user 
    @junior2 = FactoryGirl.create :junior_user 
    @event1 = FactoryGirl.create :event, game_type: 0 
    @event2 = FactoryGirl.create :event, game_type: 0 
    @mock_team = FactoryGirl.create :team, :with_events, event_count: 1
    @mock_team_invite = FactoryGirl.create :team_invite
    @event1.team = @mock_team
    @event2.team = @mock_team
    @org = @mock_team.organisers.first
    @league = FactoryGirl.create :league 
    @tenant_id = 1

    @data = {
      event_ids: [1,2],
      actor_id: 2,
      team_id: 1,
    }

    @parent_data = {
      event_ids: [1,2],
      actor_id: 2,
      team_id: 1,
      junior_ids: [3,5]
    }

    Event.stub(find: [@event1, @event2])
    Team.stub(find: @mock_team)
    TeamInvite.stub(find: @mock_team_invite)
    League.stub(find: @league)
    User.stub(:find) do |arg|
      u = @user if arg == 1
      u = @org if arg == 2
      u = @junior1 if arg == 3
      u = @parent if arg == 4
      u = [@junior1, @junior2] if arg == [3,5]
      u = [@junior1] if arg == [3]
      u = nil if arg == [6]
      u = @follower if arg == 7
      u
    end
  end

  describe '#process_schedule_data' do
    it 'should populate variables' do
      valid_data, recipient, team, league, events, team_invite_token = TeamMailer.process_schedule_data(1, @data)

      valid_data.should be_true
      # recipient.should == @user
    end
  end

  describe '#player_schedule_created' do
    it 'should be a nice schedule email' do
      mail = TeamMailer.player_schedule_created(1, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      body.should match(@event1.title)
      body.should match(@event2.title)
      body.should match("#{team_url(@mock_team, :only_path => false )}#schedule")

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
      mail.should have_subject("#{@mock_team.name}'s Schedule")
    end

    context 'when team invite link is present' do
      before :each do
        @data[:team_invite_id] = 1
      end
      it "uses link" do
        mail = TeamMailer.player_schedule_created(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@mock_team_invite.token)
      end
    end

    context 'when events do not exist' do
      before :each do
        Event.stub(find: nil)
        @data[:event_ids] = [1,2]
      end
      it "returns NullMail" do
        mail = TeamMailer.player_schedule_created(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#parent_schedule_created' do
    it 'should be a nice schedule email' do
      mail = TeamMailer.parent_schedule_created(4, @tenant_id, @parent_data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      body.should match(@event1.title)
      body.should match(@event2.title)
      body.should match("#{team_url(@mock_team, :only_path => false )}#schedule")

      mail.should deliver_to("#{@parent.name.titleize} <#{@parent.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
      mail.should have_subject("#{@mock_team.name}'s Schedule")
    end

    context 'when juniors do not exist' do
      before :each do
        @data[:junior_ids] = [6]
      end
      it "returns NullMail" do
        mail = TeamMailer.parent_schedule_created(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#follower_schedule_created' do
    it 'should be a nice schedule email' do
      mail = TeamMailer.follower_schedule_created(1, @tenant_id, @data)
      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      body.should match(@event1.title)
      body.should match(@event2.title)
      body.should match("#{team_url(@mock_team, :only_path => false )}#schedule")

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
      mail.should have_subject("#{@mock_team.name}'s Schedule")
    end

    context 'when team invite link is present' do
      before :each do
        @data[:team_invite_id] = 1
      end
      it "uses link" do
        mail = TeamMailer.follower_schedule_created(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@mock_team_invite.token)
      end
    end

    context 'when events do not exist' do
      before :each do
        Event.stub(find: nil)
        @data[:event_ids] = [1,2]
      end
      it "returns NullMail" do
        mail = TeamMailer.follower_schedule_created(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#player_schedule_updated' do
    it 'should be a nice schedule updated email' do
      mail = TeamMailer.player_schedule_updated(1, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      body.should match(@event1.title)
      body.should match(@event2.title)
      body.should match("#{team_url(@mock_team, :only_path => false )}#schedule")

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
      mail.should have_subject("Updates to #{@mock_team.name}'s Schedule")
    end

    context 'when team invite link is present' do
      before :each do
        @data[:team_invite_id] = 1
      end
      it "uses link" do
        mail = TeamMailer.player_schedule_updated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@mock_team_invite.token)
      end
    end

    context 'when events do not exist' do
      before :each do
        Event.stub(find: nil)
        @data[:event_ids] = [1,2]
      end
      it "returns NullMail" do
        mail = TeamMailer.player_schedule_updated(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#follower_schedule_updated' do
    it 'should be a nice folower schedule updated email' do
      mail = TeamMailer.follower_schedule_updated(1, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      body.should match(@event1.title)
      body.should match(@event2.title)
      body.should match("#{team_url(@mock_team, :only_path => false )}#schedule")

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
      mail.should have_subject("Updates to #{@mock_team.name}'s Schedule")
    end

    context 'when team invite link is present' do
      before :each do
        @data[:team_invite_id] = 1
      end
      it "uses link" do
        mail = TeamMailer.follower_schedule_updated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@mock_team_invite.token)
      end
    end

    context 'when events do not exist' do
      before :each do
        Event.stub(find: nil)
        @data[:event_ids] = [1,2]
      end
      it "returns NullMail" do
        mail = TeamMailer.follower_schedule_updated(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#parent_schedule_updated' do
    it 'should be a nice schedule updated email' do
      mail = TeamMailer.parent_schedule_updated(4, @tenant_id, @parent_data)
      body = mail.body.encoded

      body.should match(@parent.first_name)
      body.should match(%r{#{@mock_team.name}}i)
      body.should match(@mock_team.name.upcase)
      body.should match(@event1.title)
      body.should match(@event2.title)
      body.should match("#{team_url(@mock_team, :only_path => false )}#schedule")

      mail.should deliver_to("#{@parent.name.titleize} <#{@parent.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
      mail.should have_subject("#{[@junior1,@junior2].map(&:first_name).to_sentence}'s schedule has changed")
    end

    context 'when one junior' do
      before :each do
        @parent_data[:junior_ids] = [3]
      end
      it "should be a nice schedule updated email" do
        mail = TeamMailer.parent_schedule_updated(1, @tenant_id, @parent_data)
        mail.should_not be_a(ActionMailer::Base::NullMail)

        body = mail.body.encoded

        body.should match(@junior1.first_name)
        mail.should have_subject("#{@junior1.first_name}'s schedule has changed")
      end
    end

    context 'when one junior passed by junior_id' do
      before :each do
        @parent_data[:junior_ids] = [3]
      end
      it "should be a nice schedule updated email" do
        mail = TeamMailer.parent_schedule_updated(1, @tenant_id, @parent_data)
        mail.should_not be_a(ActionMailer::Base::NullMail)

        body = mail.body.encoded

        body.should match(@junior1.first_name)
        mail.should have_subject("#{@junior1.first_name}'s schedule has changed")
      end
    end

    context 'when juniors do not exist' do
      before :each do
        @parent_data[:junior_ids] = [6]
      end
      it "returns NullMail" do
        mail = TeamMailer.parent_schedule_updated(1, @tenant_id, @parent_data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
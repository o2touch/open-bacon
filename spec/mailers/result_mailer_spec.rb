require 'spec_helper'

describe ResultMailer do

  let(:home_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
  let(:away_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
  let(:division) do
    division = FactoryGirl.create :division_season
    TeamDSService.add_team(division, home_team)
    TeamDSService.add_team(division, away_team)
    division
  end
  let(:fixture) do
    f = FactoryGirl.create(:fixture, home_team: home_team, away_team: away_team, division_season: division)
    f.publish_edits!
    f
  end
  let(:result) do
    result = FactoryGirl.create(:soccer_result)
    result.fixture = fixture
    result.save
    result
  end
  let(:junior){ FactoryGirl.create(:junior_user) }
  let(:follower){ FactoryGirl.create(:user) }
  let(:user){ FactoryGirl.create :user }

  before :each do
    @user = FactoryGirl.create :user 
    @parent = FactoryGirl.create :user
    @follower = FactoryGirl.create :user
    @junior1 = FactoryGirl.create :junior_user 
    @junior2 = FactoryGirl.create :junior_user
    
    @home_team_invite = FactoryGirl.create :team_invite
    @org = home_team.organisers.first

    @tenant_id = 1

    @data = {
      fixture_id: fixture.id,
      actor_id: 2,
      team_id: home_team.id,
      result_id: result.id
    }

    @parent_data = {
      fixture_id: fixture.id,
      actor_id: 2,
      team_id: 1,
      junior_ids: [3,5],
      result_id: result.id
    }

    fixture.stub(:result).and_return(result)
    
    Team.stub(find: home_team)
    Fixture.stub(find: fixture)
    TeamInvite.stub(find: @home_team_invite)
    #League.stub(find: @league)
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

  describe '#process_result_data' do
    it 'should populate variables' do
      valid_data, recipient, team, league, events, team_invite_token = ResultMailer.process_result_data(1, @tenant_id, @data)

      valid_data.should be_true
    end
  end

  describe '#player_result_created' do
    it 'should be a nice result email' do
      mail = ResultMailer.player_result_created(1, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(home_team.name)
      body.should match(fixture.home_team.name)

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{home_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
    end

    context 'when team invite link is present' do
      before :each do
        @user.stub(is_registered?: false)
        # generate the power token
      end

      it "result uses link" do
        @token = PowerToken.generate_token(default_team_path(home_team), @user)
        mail = ResultMailer.player_result_created(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@token.token)
      end
    end

    context 'when fixture does not exist' do
      before :each do
        Fixture.stub(find: nil)
        @data[:fixture_id] = 1
      end
      it "returns NullMail" do
        mail = ResultMailer.player_result_created(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#parent_result_created' do
    it 'should be a nice schedule email' do
      mail = ResultMailer.parent_result_created(4, @tenant_id, @parent_data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(home_team.name)
      body.should match(away_team.name)

      mail.should deliver_to("#{@parent.name.titleize} <#{@parent.email}>")
      mail.should deliver_from("#{home_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
    end

    context 'when juniors do not exist' do
      before :each do
        @data[:junior_ids] = [6]
      end
      it "returns NullMail" do
        mail = ResultMailer.parent_result_created(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#follower_result_created' do
    it 'should be a nice schedule email' do
      mail = ResultMailer.follower_result_created(1, @tenant_id, @data)
      body = mail.body.encoded

      body.should match(home_team.name)
      body.should match(away_team.name)

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{home_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
    end
    it 'should be a nice schedule email' do
      mail = ResultMailer.follower_division_result_created(1, @tenant_id, @data)
      body = mail.body.encoded

      body.should match(home_team.name)
      body.should match(away_team.name)

      mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
      mail.should deliver_from("#{home_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
    end

    context 'when fixture do not exist' do
      before :each do
        Fixture.stub(find: nil)
        @data[:fixture_id] = 1
      end
      it "returns NullMail" do
        mail = ResultMailer.follower_result_created(1, @tenant_id, @data)
        mail.should be_a(ActionMailer::Base::NullMail)
      end
    end
  end

end
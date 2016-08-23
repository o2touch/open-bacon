require 'spec_helper'

describe UserSmser, broken: true do

  before :each do
    @follower = FactoryGirl.create :user, mobile_number: "+123456789", country: "US"
    @inviter = FactoryGirl.create :user, mobile_number: "+123456789", country: "US"

    @mock_team = FactoryGirl.create :team, :with_events, event_count: 1
    @mock_team_invite = FactoryGirl.build :team_invite, sent_by: @inviter, token: "abcdefg"

    @data = {
      team_id: 1,
    }
    
    Team.stub(find: @mock_team)

    
    User.stub(:find) do |arg|
      u = @follower if arg == 1
      u
    end
  end

  describe '#follower_registered' do
    it 'should be a nice text' do
      @follower.stub(:mobile_devices).and_return([1,2,3])
      TeamInvite.stub(:find).and_return(nil)
      sms = UserSmser.follower_registered(1, 1, @data)

      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match(@mock_team.name)
      body.should_not match("http://localhost:3000/download")

      sms.to.should == "+123456789"
    end

    it 'should contain download url if app not downloaded' do
      TeamInvite.stub(:find).and_return(nil)
      sms = UserSmser.follower_registered(1, 1, @data)
      body = sms.body
      body.should match("http://localhost:3000/download")      
    end

    it 'should contain invite if user invited to team' do
      TeamInvite.stub(find: @mock_team_invite)
      sms = UserSmser.follower_registered(1, 1, @data)
      body = sms.body
      body.should match("/team-invite")    
    end
  end

  describe '#follower_invited' do
    before :each do
      @data[:team_invite_id] = 1
    end

    it 'should be a nice text' do
      TeamInvite.stub(find: @mock_team_invite)
      sms = UserSmser.follower_invited(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match(@mock_team.name)

      sms.to.should == "+123456789"
    end

    it 'should contain download url if app not downloaded' do
      TeamInvite.stub(:find).and_return(nil)
      sms = UserSmser.follower_registered(1, 1, @data)
      body = sms.body
      body.should match("http://localhost:3000/download")      
    end

    it 'should contain invite if user invited to team' do
      TeamInvite.stub(find: @mock_team_invite)
      sms = UserSmser.follower_registered(1, 1, @data)
      body = sms.body
      body.should match("/team-invite")    
    end

    context "no team_invite" do
      before :each do
        Team.stub(find: nil)
      end

      it "errors" do
        expect{UserSmser.follower_invited(1, @data)}.to raise_error(StandardError)
      end
    end
  end

end
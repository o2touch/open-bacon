require 'spec_helper'

describe ScheduledNotificationSmser do

  describe '#member_weekly_next_game' do

    before :each do
      @member = FactoryGirl.create :user, mobile_number: "+123456789", country: "US", time_zone: "America/Phoenix"
      @mock_team = FactoryGirl.create :team, :with_events, event_count: 1
      @mock_event = FactoryGirl.build :event

      @data = {
        team_id: 1,
        event_id: 1
      }
      
      Team.stub(find: @mock_team)

      Event.stub(:find) do |arg|
        e = @mock_event if arg == 1
        e
      end
      
      User.stub(:find) do |arg|
        u = @member if arg == 1
        u
      end
    end

    it 'should be a nice text' do
      @mock_event.stub(:game_type).and_return(GameTypeEnum::GAME)
      sms = ScheduledNotificationSmser.member_weekly_next_game(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body
      
      time_str = @mock_event.bftime.pp_sms_time

      body.should == "NEXT GAME: #{@mock_team.name} #{@mock_event.title} - #{time_str} - Download the app: http://127.0.0.1/download"

      sms.to.should == "+123456789"
    end
  end

end
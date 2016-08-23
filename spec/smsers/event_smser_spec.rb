require 'spec_helper'

describe EventSmser, broken: true do

  before :each do
    @member = FactoryGirl.create :user, mobile_number: "+123456789", country: "US", time_zone: "America/Phoenix"
    @member_gb = FactoryGirl.create :user, mobile_number: "+123456789", country: "GB", time_zone: "Europe/London"
    @inviter = FactoryGirl.create :user, mobile_number: "+123456789", country: "US"

    @mock_team = FactoryGirl.create :team, :with_events, event_count: 1
    @mock_event = FactoryGirl.build :event
    @mock_event_2 = FactoryGirl.build :event, time: Time.new(2014,10,29,15,0,0,0), time_zone: "UTC"

    @data = {
      team_id: 1,
      event_id: 1
    }
    
    Team.stub(find: @mock_team)

    Event.stub(:find) do |arg|
      e = @mock_event if arg == 1
      e = @mock_event_2 if arg == 2
      e
    end
    
    User.stub(:find) do |arg|
      u = @member if arg == 1
      u = @member_gb if arg == 2
      u
    end
  end

  describe '#member_event_created' do
    it 'should be a nice text' do
      sms = EventSmser.member_event_created(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match(@mock_team.name)
      body.should match "NEW"
      body.should match "#{@mock_event.game_type_string.upcase}"

      sms.to.should == "+123456789"
    end

    context "locale is GB" do
      it 'should show dates in GB' do
        @data[:event_id] = 2

        sms = EventSmser.member_event_created(2, 1, @data)
        sms.should_not be_a(NullSms)

        body = sms.body

        body.should match "Wed 29th Oct 15:00"
      end
    end

    context "locale is US" do
      it 'should show dates in US format' do
        @data[:event_id] = 2

        sms = EventSmser.member_event_created(1, 1, @data)
        sms.should_not be_a(NullSms)

        body = sms.body

        body.should match "Wed Oct 29th 3:00pm"
      end
    end
  end

  describe '#member_event_postponed' do
    it 'should be a nice text' do
      sms = EventSmser.member_event_postponed(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match(@mock_team.name)
      body.should match "POSTPONED"
      body.should match "#{@mock_event.game_type_string.upcase}"

      sms.to.should == "+123456789"
    end

    context "locale is GB" do
      it 'should show dates in GB' do
        @data[:event_id] = 2

        sms = EventSmser.member_event_postponed(2, 1, @data)
        sms.should_not be_a(NullSms)

        body = sms.body

        body.should match "Wed 29th Oct 15:00"
      end
    end

    context "locale is US" do
      it 'should show dates in US format' do
        @data[:event_id] = 2

        sms = EventSmser.member_event_postponed(1, 1, @data)
        sms.should_not be_a(NullSms)

        body = sms.body

        body.should match "Wed Oct 29th 3:00pm"
      end
    end
  end

  describe '#member_event_rescheduled' do
    before :each do
      @data[:team_invite_id] = 1
    end

    it 'should be a nice text' do
      sms = EventSmser.member_event_rescheduled(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match "RESCHEDULED"
      body.should match "#{@mock_event.game_type_string.upcase}"

      sms.to.should == "+123456789"
    end
  end

  describe '#member_event_activated' do
    it 'should be a nice text' do
      sms = EventSmser.member_event_activated(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match @mock_team.name
      body.should match "#{@mock_event.game_type_string.upcase}"
      body.should match "BACK ON"

      sms.to.should == "+123456789"
    end
  end

  describe '#member_event_cancelled' do
    it 'should be a nice text' do
      sms = EventSmser.member_event_cancelled(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match(@mock_team.name)
      body.should match "#{@mock_event.game_type_string.upcase}"
      body.should match "CANCELLED"

      sms.to.should == "+123456789"
    end
  end

  describe '#member_event_updated' do
    it 'should be a nice text' do
      sms = EventSmser.member_event_updated(1, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body

      body.should match(@mock_team.name)
      body.should match "#{@mock_event.game_type_string.upcase}"
      body.should match "UPDATED"

      sms.to.should == "+123456789"
    end
  end

  describe '#player_or_parent_event_reminder' do
    it 'should send some well safe text, fam' do
      User.unstub(:find)
      tse = FactoryGirl.create :teamsheet_entry
      @data[:tse_id] = tse.id
      @data[:actor_id] = @member_gb.id
      @data[:sms_reply_code] = 1

      sms = EventSmser.player_or_parent_event_invite_reminder(@member.id, 1, @data)
      sms.should_not be_a(NullSms)

      body = sms.body
      body.should match "Can you make it"
      body.should match "Text back Y1 or N1"

      sms.to.should == "+123456789"
    end
  end

end
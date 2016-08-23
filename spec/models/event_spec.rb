require 'spec_helper'

describe Event do

  context 'event factory' do
    it "is valid" do
      event = FactoryGirl.create(:event)
      event.should be_valid
      event.user.should_not be_nil
      event.team.should be_nil
    end
  end

  describe 'validations' do
    it 'can only have one fixture' do
      event = FactoryGirl.build :event
      fx_one = FactoryGirl.build :fixture
      fx_two = FactoryGirl.build :fixture

      event.home_fixture = fx_one
      event.away_fixture = fx_two

      event.should_not be_valid
    end
  end

  context 'when in Europe/London time zone' do

    before :each do
      team = FiveASideTeam.new
      @event = team.event
      @event.time_zone = "Europe/London"
      @tz = TZInfo::Timezone.get(@event.time_zone) 
    end

    it 'setting the local time in DST saves in UTC' do
      eventTime = @tz.utc_to_local(Time.local(2012,10,17,10,0,0))

      @event.time_local = eventTime.to_s

      @event.time_local.to_s.should eq "2012-10-17 11:00:00 UTC"
      @event.time.getutc.to_s.should eq "2012-10-17 10:00:00 UTC"
    end

    it 'setting the local time (non DST) saves in UTC' do
      eventTime = @tz.utc_to_local(Time.local(2012,12,17,7,0,0))

      @event.time_local = eventTime.to_s

      @event.time_local.to_s.should eq "2012-12-17 07:00:00 UTC"
      @event.time.getutc.to_s.should eq "2012-12-17 07:00:00 UTC"
    end
    it 'setting the time in DST saves in UTC' do
      eventTime = @tz.local_to_utc(Time.local(2012,10,17,10,0,0))

      @event.time = eventTime.to_s

      @event.time.getutc.to_s.should eq "2012-10-17 09:00:00 UTC"
    end
    it 'setting the time (non DST) saves in UTC' do
      eventTime = @tz.local_to_utc(Time.local(2012,12,17,7,0,0))

      @event.time = eventTime.to_s

      @event.time.getutc.to_s.should eq "2012-12-17 07:00:00 UTC"
    end
  end

  context 'when in America/Phoenix time zone' do
    
    before :each do
      team = FiveASideTeam.new
      @event = team.event
      @event.time_zone = "America/Phoenix"
      @tz = TZInfo::Timezone.get(@event.time_zone) 
    end

    it 'setting the local time saves in UTC' do
      eventTime = @tz.utc_to_local(Time.local(2012,10,17,7,0,0))

      @event.time_local = eventTime.to_s

      @event.time_local.to_s.should eq "2012-10-17 00:00:00 UTC"
      @event.time.getutc.to_s.should eq "2012-10-17 07:00:00 UTC"
    end
    it 'setting the local time saves in UTC' do
      eventTime = @tz.utc_to_local(Time.local(2012,12,17,7,0,0))

      @event.time_local = eventTime.to_s

      @event.time_local.to_s.should eq "2012-12-17 00:00:00 UTC"
      @event.time.getutc.to_s.should eq "2012-12-17 07:00:00 UTC"
    end
  end

  context 'organiser message' do
    it 'validates the miniumum length of the message' do
      FactoryGirl.build(:event_message, :text => "").valid?.should be_false
      FactoryGirl.build(:event_message, :text => "x").valid?.should be_true
    end

    it 'validates the maximum length of the message' do
      FactoryGirl.build(:event_message, :text => "x"*FieldValidation::MAXIMUM_MESSAGE_LENGTH).valid?.should be_true
      FactoryGirl.build(:event_message, :text => "x"*(FieldValidation::MAXIMUM_MESSAGE_LENGTH+1)).valid?.should be_false
    end
  end

  describe "#cached_teamsheet_entries" do
    it "returns teamsheet entries" do
      @event = FactoryGirl.create(:event)
      user = mock_model(User)
      @event.teamsheet_entries.stub(:find).and_return(@event.teamsheet_entries)

      (1..4).each do |i|
        if i <= 2
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::AVAILABLE, :user=>user)
        else
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::UNAVAILABLE, :user=>user)
        end
        @event.teamsheet_entries << tse
      end

      @event.cached_teamsheet_entries.size.should == 4
    end
  end 

  describe "#teamsheet_entries_available" do
    before (:each) do
      @event = FactoryGirl.create(:event)

      user = mock_model(User)
      @event.teamsheet_entries.stub(:find).and_return(@event.teamsheet_entries)

      (1..10).each do |i|

        if i <= 2
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::AVAILABLE, :user=>user)
        elsif i <= 5
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::UNAVAILABLE, :user=>user)
        else
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::AWAITING_RESPONSE, :user=>user)
        end

        @event.teamsheet_entries << tse
      end
    end

    context "with all available players" do
      it "returns available players" do
        players = @event.teamsheet_entries_available
        players.size.should == 2
      end
    end
  end

  describe "#teamsheet_entries_filter_by_response_status" do
    before (:each) do
      @event = FactoryGirl.create(:event)

      user = mock_model(User)
      @event.teamsheet_entries.stub(:find).and_return(@event.teamsheet_entries)

      (1..10).each do |i|

        if i <= 2
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::AVAILABLE, :user=>user)
        elsif i <= 5
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::UNAVAILABLE, :user=>user)
        else
          tse = mock_model(TeamsheetEntry,:[]= => nil, :save=> nil, :response_status =>  InviteResponseEnum::AWAITING_RESPONSE, :user=>user)
        end

        @event.teamsheet_entries << tse
      end
    end

    context "with all available players" do
      it "returns available players" do
        players = @event.teamsheet_entries_filter_by_response_status([InviteResponseEnum::AVAILABLE])
        players.size.should == 2
      end
    end

    context "with all unavailable players" do
      it "returns unavailable players" do
        players = @event.teamsheet_entries_filter_by_response_status([InviteResponseEnum::UNAVAILABLE])
        players.size.should == 3
      end
    end

    context "with all players awaiting response" do
      it "returns unavailable players" do
        players = @event.teamsheet_entries_filter_by_response_status([InviteResponseEnum::AWAITING_RESPONSE])
        players.size.should == 5
      end
    end
  end
end

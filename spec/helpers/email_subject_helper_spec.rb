require 'spec_helper'

include EmailSubjectHelper

# Factories are used here rather than Mocks for ease of maintenance
describe "EmailSubjectHelper" do

  let(:team) { FactoryGirl.build(:team) }
  let(:recipient) { FactoryGirl.build(:user, :name => "John Lakes") }
  let(:junior) { FactoryGirl.build(:junior_user, :name => "Leo Lakes") }
  let(:junior2) { FactoryGirl.build(:junior_user) }

  describe "#subject_for_event_schedule" do
    it { subject_for_event_schedule(team).should == "#{team.name}'s Schedule" }
  end

  describe "#subject_for_event_schedule_update" do
    it { subject_for_event_schedule_update(team).should == "Updates to #{team.name}'s Schedule" }
    it { subject_for_event_schedule_update(team, junior).should == "#{junior.first_name.titleize}\'s schedule has changed" }
    it { subject_for_event_schedule_update(team, [junior,junior2]).should == "#{junior.first_name.titleize} and #{junior2.first_name.titleize}\'s schedule has changed" }
  end

  describe "#subject_for_user_weekly_schedule" do
    it { subject_for_user_weekly_schedule(recipient).should == "John, here are the games & events for this week" }
  end

describe "#subject_for_parent_weekly_schedule" do
  it { subject_for_parent_weekly_schedule(recipient, junior).should == "John, here are Leo's upcoming events" }
end

  describe "#subject_for_invite" do

    context "with time" do
      let(:event) { FactoryGirl.build(:event, :time => Time.new(2013,4,1,10,0,0,"+00:00"), :time_zone => "America/Los_Angeles") } # Monday 01 Apr 2013 03:00      event = double(Event
      it { subject_for_invite(event).should == "Available at 3:00am Monday, 1st Apr?" }
    end

    context "without time" do
      let(:event) { FactoryGirl.build(:event, :time => nil) } # Monday 01 Apr 2013 03:00
      it { subject_for_invite(event).should == "Available at ?" }
    end
  end
  
  describe "#subject_for_message_posted" do
    let(:message) { FactoryGirl.build(:event_message) }
    it { subject_for_message_posted(message).should == "#{message.user.name} posted a message" }
  end

  describe "#subject_for_invite_reminder" do
    context "when game" do
      it 'returns game with day' do
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => Time.new(2013,4,1,10,0,0,"+00:00")) 
        subject_for_invite_reminder(event).should == "Reminder: Can you play in the game at 3:00am Monday, 1st Apr?" 
        subject_for_invite_reminder(event, junior).should == "Reminder: Can #{junior.first_name.titleize} play in the game at 3:00am Monday, 1st Apr?" 
      end
    end

    context "when practice" do
      it 'returns practice with day' do
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => Time.new(2013,4,1,10,0,0,"+00:00")) 
        subject_for_invite_reminder(event).should == "Reminder: Can you play in the practice at 3:00am Monday, 1st Apr?"
        subject_for_invite_reminder(event, junior).should == "Reminder: Can #{junior.first_name.titleize} play in the practice at 3:00am Monday, 1st Apr?"
      end
    end

    context "when event" do
      it 'returns event with day' do
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => Time.new(2013,4,1,10,0,0,"+00:00"))
        subject_for_invite_reminder(event).should == "Reminder: Can you play in the event at 3:00am Monday, 1st Apr?"
        subject_for_invite_reminder(event, junior).should == "Reminder: Can #{junior.first_name.titleize} play in the event at 3:00am Monday, 1st Apr?"
      end
    end
  end

  describe "#subject_for_event_reminder" do

    context "when game" do
      it "returns game with day" do
        time = Time.now + 6.days
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
        day = time.in_time_zone(event.time_zone).strftime("%A")
        subject_for_event_reminder(event).should == "Don't forget the game on #{day.titleize}"
      end
      it "returns game with tomorrow" do
        time = Time.now + 23.hours
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
        subject_for_event_reminder(event).should == "Don't forget the game tomorrow"
      end
    end

    context "when practice" do
      it "returns practice with day" do
        time = Time.now + 6.days
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => time, :time_zone => "America/Los_Angeles")
        day = time.in_time_zone(event.time_zone).strftime("%A")
        subject_for_event_reminder(event).should == "Don't forget the practice on #{day.titleize}"
      end
      it "returns practice with tomorrow" do
        time = Time.now + 23.hours
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => time, :time_zone => "America/Los_Angeles")
        subject_for_event_reminder(event).should == "Don't forget the practice tomorrow"
      end
    end

    context "when event" do
      it "returns event with day" do
        time = Time.now + 6.days
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => time, :time_zone => "America/Los_Angeles")
        day = time.in_time_zone(event.time_zone).strftime("%A")
        subject_for_event_reminder(event).should == "Don't forget the event on #{day.titleize}"
      end
      it "returns practice with tomorrow" do
        time = Time.now + 23.hours
        event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => time, :time_zone => "America/Los_Angeles")
        subject_for_event_reminder(event).should == "Don't forget the event tomorrow"
      end
    end
    
  end

  describe "#subject_for_scheduled_event_reminder_single" do
    context "when adult" do
      context "when game" do
        it "returns game with day" do
          time = Time.now + 6.days
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          subject_for_scheduled_event_reminder_single(event).should == "Reminder: You are available for a game on #{day.titleize}"
        end
        it "returns game with tomorrow" do
          time = Time.now + 23.hours
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          subject_for_scheduled_event_reminder_single(event).should == "Reminder: You are available for a game tomorrow"
        end
      end

      context "when practice" do
        it "returns practicewith day" do
          time = Time.now + 6.days
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          subject_for_scheduled_event_reminder_single(event).should == "Reminder: You are available for a practice on #{day.titleize}"
        end
        it "returns practice with tomorrow" do
          time = Time.now + 23.hours
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => time, :time_zone => "America/Los_Angeles")
          subject_for_scheduled_event_reminder_single(event).should == "Reminder: You are available for a practice tomorrow"
        end
      end

      context "when event" do
        it "returns event with day" do
          time = Time.now + 6.days
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          subject_for_scheduled_event_reminder_single(event).should == "Reminder: You are available for an event on #{day.titleize}"
        end
        it "returns event with tomorrow" do
          time = Time.now + 23.hours
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => time, :time_zone => "America/Los_Angeles")
          subject_for_scheduled_event_reminder_single(event).should == "Reminder: You are available for an event tomorrow"
        end
      end
    end

    context "when junior user" do

      before(:each) do
        junior.name = "Leo Gentile"
        @leo = junior
      end

      context "when game" do
        it "returns game with day" do
          time = Time.now + 6.days
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          subject_for_scheduled_event_reminder_single(event, @leo).should == "Reminder: Leo is available for a game on #{day.titleize}"
        end
        it "returns game with tomorrow" do
          time = Time.now + 23.hours
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          subject_for_scheduled_event_reminder_single(event, @leo).should == "Reminder: Leo is available for a game tomorrow"
        end
      end

      context "when practice" do
        it "returns practicewith day" do
          time = Time.now + 6.days
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          subject_for_scheduled_event_reminder_single(event, @leo).should == "Reminder: Leo is available for a practice on #{day.titleize}"
        end
        it "returns practice with tomorrow" do
          time = Time.now + 23.hours
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE, :time => time, :time_zone => "America/Los_Angeles")
          subject_for_scheduled_event_reminder_single(event, @leo).should == "Reminder: Leo is available for a practice tomorrow"
        end
      end

      context "when event" do
        it "returns event with day" do
          time = Time.now + 6.days
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          subject_for_scheduled_event_reminder_single(event, @leo).should == "Reminder: Leo is available for an event on #{day.titleize}"
        end
        it "returns event with tomorrow" do
          time = Time.now + 23.hours
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT, :time => time, :time_zone => "America/Los_Angeles")
          subject_for_scheduled_event_reminder_single(event, @leo).should == "Reminder: Leo is available for an event tomorrow"
        end
      end
    end
  end

  describe "#subject_for_scheduled_event_reminder_multiple" do

    before :each do
      @tse = FactoryGirl.build_list(:teamsheet_entry, 3)
    end

    context "when adult" do
      context "when all same day" do
        it "returns size with day" do
          time = Time.now + 6.days
    
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          @tse[0].event = event

          subject_for_scheduled_event_reminder_multiple(@tse, true).should == "Reminder: You are available for 3 events on #{day.titleize}"
        end
        it "returns size with tomorrow" do
          time = Time.now + 23.hours
          
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          @tse[0].event = event

          subject_for_scheduled_event_reminder_multiple(@tse, true).should == "Reminder: You are available for 3 events tomorrow"
        end
      end

      context "when different days" do
        it "returns size with coming up" do
            time = Time.now + 6.days

            event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
            day = time.in_time_zone(event.time_zone).strftime("%A")
            @tse[0].event = event

            subject_for_scheduled_event_reminder_multiple(@tse, false).should == "Reminder: You are available for 3 events"
        end
      end
    end

    context "when junior user" do

      before(:each) do
        junior.name = "Leo Gentile"
        @leo = junior
      end

      context "when all same day" do
        it "returns size with day" do
          time = Time.now + 6.days

          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          day = time.in_time_zone(event.time_zone).strftime("%A")
          @tse[0].event = event

          subject_for_scheduled_event_reminder_multiple(@tse, true, @leo).should == "Reminder: Leo is available for 3 events on #{day.titleize}"
        end
        it "returns size with coming up" do
          time = Time.now + 23.hours
          
          event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
          @tse[0].event = event

          subject_for_scheduled_event_reminder_multiple(@tse, true, @leo).should == "Reminder: Leo is available for 3 events tomorrow"
        end
      end

      context "when different days" do
        it "returns size with coming up" do
            time = Time.now + 6.days

            event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME, :time => time, :time_zone => "America/Los_Angeles")
            day = time.in_time_zone(event.time_zone).strftime("%A")
            @tse[0].event = event

            subject_for_scheduled_event_reminder_multiple(@tse, false, @leo).should == "Reminder: Leo is available for 3 events"
        end
      end

    end

  end

  describe "#subject_for_event_cancelled" do
    before :each do
      junior.name = "Leo Gentile"
      @leo = junior
    end

    context "when game" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
      end

      it { subject_for_event_cancelled(@event).should == "Your game has been cancelled!" }
      it { subject_for_event_cancelled(@event, @leo).should == "Leo\'s game has been cancelled!" }
    end

    context "when practice" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE)
      end

      it { subject_for_event_cancelled(@event).should == "Your practice has been cancelled!" }
      it { subject_for_event_cancelled(@event, @leo).should == "Leo\'s practice has been cancelled!" }
    end

    context "when event" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT)
      end

      it { subject_for_event_cancelled(@event).should == "Your event has been cancelled!" }
      it { subject_for_event_cancelled(@event, @leo).should == "Leo\'s event has been cancelled!" }
    end
  end

  describe "#subject_for_event_activated" do
    before :each do
      junior.name = "Leo Gentile"
      @leo = junior
    end

    context "when game" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
      end

      it { subject_for_event_activated(@event).should == "Your game is back on!" }
      it { subject_for_event_activated(@event, @leo).should == "Leo\'s game is back on!" }
    end

    context "when practice" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE)
      end

      it { subject_for_event_activated(@event).should == "Your practice is back on!" }
      it { subject_for_event_activated(@event, @leo).should == "Leo\'s practice is back on!" }
    end

    context "when event" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT)
      end

      it { subject_for_event_activated(@event).should == "Your event is back on!" }
      it { subject_for_event_activated(@event, @leo).should == "Leo\'s event is back on!" }
    end
  end

  describe "#subject_for_event_details_updated" do
    before :each do
      junior.name = "Leo Gentile"
      @leo = junior
    end

    context "when game" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
      end

      it { subject_for_event_details_updated(@event).should == "Your game has been updated" }
      it { subject_for_event_details_updated(@event, @leo).should == "Leo\'s game has been updated" }
    end

    context "when practice" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::PRACTICE)
      end

      it { subject_for_event_details_updated(@event).should == "Your practice has been updated" }
      it { subject_for_event_details_updated(@event, @leo).should == "Leo\'s practice has been updated" }
    end

    context "when event" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::EVENT)
      end

      it { subject_for_event_details_updated(@event).should == "Your event has been updated" }
      it { subject_for_event_details_updated(@event, @leo).should == "Leo\'s event has been updated" }
    end
  end

  describe "#subject_for_new_user_invited_to_team" do
    before :each do
      @team = FactoryGirl.build(:team)
      @team.name = "Santa Monica Lions"
    end

    context "adult" do
      it { subject_for_new_user_invited_to_team(@team).should == "Your invitation to join Santa Monica Lions on Mitoo" }
      it { subject_for_new_user_invited_to_team(@team).should == "Your invitation to join Santa Monica Lions on Mitoo" }
    end

    context "junior" do
      before :each do
        junior.name = "Leo Gentile"
        @leo = junior
      end

      it { subject_for_new_user_invited_to_team(@team, @leo).should == "Leo\'s invitation to join Santa Monica Lions on Mitoo" }
      it { subject_for_new_user_invited_to_team(@team, @leo).should == "Leo\'s invitation to join Santa Monica Lions on Mitoo" }
    end
  end

  describe "#subject_for_follower_event_cancelled" do
    context "event" do
      before :each do
        @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
      end
      it { subject_for_follower_event_cancelled(@event).should == "A game has been cancelled!" }
    end
  end

  describe "#subject_for_follower_event_activated" do
    before :each do
      @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
    end

    context "event" do
      it { subject_for_follower_event_activated(@event).should == "A game is back on!" }
    end
  end

  describe "#subject_for_follower_event_postponed" do
    before :each do
      @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
    end

    context "event" do
      it { subject_for_follower_event_postponed(@event).should == "A game has been postponed!" }
    end
  end

  describe "#subject_for_follower_event_rescheduled" do
    before :each do
      @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
    end

    context "event" do
      it { subject_for_follower_event_rescheduled(@event).should == "A game has been rescheduled!" }
    end
  end

  describe "#subject_for_follower_event_updated" do
    before :each do
      @event = FactoryGirl.build(:event, :game_type => GameTypeEnum::GAME)
    end

    context "event" do
      it { subject_for_follower_event_updated(@event).should == "A game has been updated" }
    end
  end

  describe "#subject_for_result_created" do

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
      result.to_yaml
      result
    end

    context "won" do
      before :each do
        fixture.stub(:result).and_return(result)
      end
      it { subject_for_result_created(result, home_team).should == "#{home_team.name} WON 2:1 vs #{away_team.name}" }
    end

    context "lost" do
      before :each do
        result.home_score = HashWithIndifferentAccess.new(0)
        fixture.stub(:result).and_return(result)
      end
      it { subject_for_result_created(result, home_team).should == "#{home_team.name} LOST 1:0 vs #{away_team.name}" }
    end

    context "draw" do
      before :each do
        result.home_score = HashWithIndifferentAccess.new(1)
        fixture.stub(:result).and_return(result)
      end
      it { subject_for_result_created(result, home_team).should == "#{home_team.name} DREW 1:1 vs #{away_team.name}" }
    end
  end
end
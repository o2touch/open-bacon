require 'spec_helper'
describe Ns2::Processors::EventsProcessor do

  context "when an event for an adult team is" do

    def all_comms(u)
      u.stub(email: "asdfasd@sadfasd.org.uk")
      u.stub(mobile_number: "1234029837")
      u.stub(pushable_mobile_devices: ["hi"])
    end

    def email_sms_comms(u)
      u.stub(email: "asdfasd@sadfasd.org.uk")
      u.stub(mobile_number: "1234029837")
      u.stub(pushable_mobile_devices: [])
    end

    def sms_comms(u)
      u.stub(email: nil)
      u.stub(mobile_number: "1234029837")
      u.stub(pushable_mobile_devices: [])
    end

    def email_comms(u)
      u.stub(email: "asdfasd@sadfasd.org.uk")
      u.stub(mobile_number: nil)
      u.stub(pushable_mobile_devices: [])
    end

    before :each do
      @team = FactoryGirl.create :team, :with_events, event_count: 1
      @organiser = @team.organisers.first

      @event = @team.events.first
      @event.time = Time.now + 3.days
      @event.team = @team

      @player = FactoryGirl.create :user, name: "Jack"
      all_comms(@player)

      @player_david = FactoryGirl.create :user, name: "David"
      email_comms(@player_david)

      @player_john = FactoryGirl.create :user, name: "John"
      sms_comms(@player_john)

      @follower = FactoryGirl.create :user, name: "Pete"
      all_comms(@follower)

      @follower_dylan = FactoryGirl.create :user, name: "Dylan"
      email_comms(@follower_dylan)

      @follower_mike = FactoryGirl.create :user, name: "Mike"
      sms_comms(@follower_mike)

      # Mitoo users
      @follower_ben = FactoryGirl.create :user, name: "Ben"
      email_comms(@follower_ben)

      @follower_alfredo = FactoryGirl.create :user, name: "Alfredo"
      email_comms(@follower_alfredo)

      @team.stub(:associates) { [ @player, @player_david, @player_john, @follower, @follower_dylan, @follower_mike, @follower_ben, @follower_alfredo ]}
      @team.stub(:has_player?) do |args|
        r = true if args.id==@player.id
        r = true if args.id==@player_david.id
        r = true if args.id==@player_john.id
        r
      end
      
      @team.stub(:has_follower?) do |args|
        r = true if args.id==@follower.id
        r = true if args.id==@follower_david.id
        r = true if args.id==@follower_john.id
        r = true if args.id==@follower_ben.id
        r = true if args.id==@follower_alfredo.id
        r
      end

      # App Event
      @ae = AppEvent.new({
        obj: @event,
        subj: @organiser,
        meta_data: {},
        processed_at: nil
      })
      AppEvent.stub(find: @ae)
    end

    describe '#created' do

      it 'creates correct notifications' do
        @ae.verb = "created"
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), "follower_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), "follower_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), "follower_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, anything(), anything())

        # Ben - (Mitoo Registered) Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_ben, kind_of(Tenant), "follower_event_created", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_ben, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_ben, anything(), anything())

        # Alfredo - (Mitoo Invited) Follower SMS
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(@ae, @follower_alfredo, kind_of(Tenant), "follower_event_created", kind_of(Hash))
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(anything(), @follower_alfredo, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_alfredo, anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.verb = "created"
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @ae.verb = "created"
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'does not create notifications if should not notify due to UserTeamNotificationPolicy' do
        @ae.verb = "created"

        do_not_notify = double("UserTeamNotificationPolicy")
        do_not_notify.stub(:should_notify?).and_return(false)

        UserTeamNotificationPolicy.stub(:new).and_return(do_not_notify)

        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates notifications if should notify due to UserTeamNotificationPolicy' do
        @ae.verb = "created"
        
        do_not_notify = double("UserTeamNotificationPolicy")
        do_not_notify.stub(:should_notify?).and_return(true)

        UserTeamNotificationPolicy.stub(:new).and_return(do_not_notify)

        Ns2::Processors::EventsProcessor.should_receive(:email_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.process(1)
      end
    end

    describe '#updated' do

      before :each do
        @ae.verb = "updated"
      end

      it 'creates correct notifications' do
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_updated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_updated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_updated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), "follower_event_updated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), "follower_event_updated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), "follower_event_updated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'does not create notifications if should not notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(false)

        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates notifications if should notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(true)

        Ns2::Processors::EventsProcessor.should_receive(:email_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.process(1)
      end
    end

    describe '#cancelled' do

      before :each do
        @ae.verb = "cancelled"
      end

      it 'creates correct notifications' do
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_cancelled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_cancelled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_cancelled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), "follower_event_cancelled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), "follower_event_cancelled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), "follower_event_cancelled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'does not create notifications if should not notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(false)

        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates notifications if should notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(true)

        Ns2::Processors::EventsProcessor.should_receive(:email_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.process(1)
      end
    end 


    describe '#activated' do

      before :each do
        @ae.verb = "activated"
      end

      it 'creates correct notifications' do
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_activated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_activated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, kind_of(Tenant), kind_of(Tenant), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_activated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, kind_of(Tenant), anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), "follower_event_activated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, kind_of(Tenant), kind_of(Tenant), kind_of(Tenant), anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), "follower_event_activated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), "follower_event_activated", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, kind_of(Tenant), anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'does not create notifications if should not notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(false)

        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates notifications if should notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(true)

        Ns2::Processors::EventsProcessor.should_receive(:email_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.process(1)
      end
    end


    describe '#postponed' do

      before :each do
        @ae.verb = "postponed"
      end

      it 'creates correct notifications' do
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_postponed", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_postponed", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_postponed", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), "follower_event_postponed", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), "follower_event_postponed", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), "follower_event_postponed", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'does not create notifications if should not notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(false)

        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates notifications if should notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(true)

        Ns2::Processors::EventsProcessor.should_receive(:email_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.process(1)
      end
    end

    describe '#rescheduled' do

      before :each do
        @ae.verb = "rescheduled"
      end

      it 'creates correct notifications' do
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_rescheduled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_rescheduled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_rescheduled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), "follower_event_rescheduled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), "follower_event_rescheduled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), "follower_event_rescheduled", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'does not create notifications if should not notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(false)

        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates notifications if should notify due to UserTeamNotificationPolicy' do
        UserNotificationsPolicy.any_instance.stub(:should_notify?).and_return(true)

        Ns2::Processors::EventsProcessor.should_receive(:email_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).at_least(1).times
        Ns2::Processors::EventsProcessor.process(1)
      end
    end 

    describe '#deleted' do

      before :each do
        @ae.verb = "deleted"
      end

      it 'creates no player notifications' do
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if notify = false' do
        @ae.meta_data[:notify] = false
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end

      it 'creates no player notifications if event is more than 7 days away' do
        @event.time = Time.now + 14.days
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni)
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni)
        Ns2::Processors::EventsProcessor.process(1)
      end
    end 

    describe '#reminder' do

      before :each do
        @ae.verb = "invite_reminder"
        TeamsheetEntry.stub(find_by_event_and_user: double(id: 1, invite_responses: []))
      end

      it 'creates correct notifications' do
        
        # Jack - Player Push
        Ns2::Processors::EventsProcessor.should_receive(:push_ni).with(@ae, @player, kind_of(Tenant), "player_event_invite_reminder", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player, kind_of(Tenant), "player_event_invite_reminder", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player, anything(), anything())

        # David - Player Email
        Ns2::Processors::EventsProcessor.should_receive(:email_ni).with(@ae, @player_david, kind_of(Tenant), "player_event_invite_reminder", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_david, kind_of(Tenant), kind_of(Tenant), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @player_david, anything(), anything())

        # John - Player SMS
        Ns2::Processors::EventsProcessor.should_receive(:sms_ni).with(@ae, @player_john, kind_of(Tenant), "player_event_invite_reminder", kind_of(Hash)).and_return(double(process: nil))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @player_john, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @player_john, kind_of(Tenant), anything(), anything())

        # Pete - Follower Push
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(@ae, @follower, kind_of(Tenant), anything(), kind_of(Hash))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower, kind_of(Tenant), kind_of(Tenant), kind_of(Tenant), anything(), anything())
        
        # Dylan - Follower Email
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(@ae, @follower_dylan, kind_of(Tenant), anything(), kind_of(Hash))
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_dylan, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(anything(), @follower_dylan, anything(), anything())

        # Mike - Follower SMS
        Ns2::Processors::EventsProcessor.should_not_receive(:sms_ni).with(@ae, @follower_mike, kind_of(Tenant), anything(), kind_of(Hash))
        Ns2::Processors::EventsProcessor.should_not_receive(:email_ni).with(anything(), @follower_mike, kind_of(Tenant), anything(), anything())
        Ns2::Processors::EventsProcessor.should_not_receive(:push_ni).with(anything(), @follower_mike, kind_of(Tenant), anything(), anything())

        Ns2::Processors::EventsProcessor.process(1)
      end
    end
  end
end
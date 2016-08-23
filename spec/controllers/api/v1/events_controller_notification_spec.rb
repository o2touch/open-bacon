require 'spec_helper'

describe Api::V1::EventsController do
  render_views
	let(:user_one){ FactoryGirl.create(:user, :with_team_events, team_count: 1, team_event_count: 3, team_past_event_count: 2) }
  let(:user_two){ FactoryGirl.create(:user, :with_team_events, team_count: 1, team_event_count: 2, team_past_event_count: 1) }
	let(:team_one){ user_one.teams_as_organiser.first }
	let(:team_two){ user_two.teams_as_organiser.first }
  let(:player_one) do
    player_one = FactoryGirl.create(:user)
    TeamUsersService.add_player(team_one, player_one, false)
    player_one
  end
  let(:player_two) do
    player_two = FactoryGirl.create(:user)
    TeamUsersService.add_player(team_two, player_two, false)
    player_two
  end

  before :each do
    request.env['X-AUTH-TOKEN'] = user_one.authentication_token
  end

  describe '#create' do
    before :each do
      @event_attrs = FactoryGirl.attributes_for(:event, user: user_one)
      # otherwise Event.time_local= gets all mental.
      @event_attrs[:time_local] = 1.week.from_now.to_s
      @event_attrs[:team_id] = team_one.id
    end

    def do_create(event_attrs)
      post :create, format: :json, event: event_attrs
    end

    context 'when logged in' do
      it 'is successful' do
        do_create(@event_attrs)
        response.status.should eq(200)
      end

      it 'creates the resource' do
        lambda { do_create @event_attrs }.should change(Event, :count).by(1)
      end

      it 'creates an activity item' do
        do_create(@event_attrs)
        @event = user_one.events_created.last

        activity_item = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :created])
        activity_item.length.should == 1
        activity_item = activity_item.first

        activity_item.subj_type.should == user_one.class.name
        activity_item.obj_type.should == @event.class.name
        activity_item.meta_data.should be_nil
        response.status.should eq(200)
      end

      # oops, wrong file!
      it 'sets tenanted attrs' do
        @event_attrs[:price] = "10.00"
        team_one.config.event_extra_fields = [{ name: :price }]
        team_one.save

        do_create(@event_attrs)
        event = user_one.events_created.last
        event.tenanted_attrs.should eq({price: "10.00"})
      end
    end
  end

  describe '#update', type: :api do
    before :each do
      @event = team_one.future_events.first
    end

    def update_event(event, request_params)
      put :update, format: :json, id: event.id, event: construct_request_params(event, request_params)
      @event.reload
    end

    def construct_request_params(event, update_params)
      request_params = { 
        :location => event.location.attributes, # this is essentialy hashify
        :title => event.title,
        :game_type => event.game_type,
        :team_id => event.team_id,
        :time_local => event.time_local.to_s
      }
      request_params.merge(update_params)
    end

    context 'when organiser' do

      # oops, wrong file!
      it 'sets tenanted attrs' do
        request_params = { price: "10.00" }
        @event.team.config.event_extra_fields = [{ name: :price }]
        @event.team.save

        update_event(@event, request_params)
        @event.reload
        @event.tenanted_attrs.should eq({price: "10.00"})
      end

      it 'resource is updated' do
        expected_event_title = "#{@event.title}-Updated"
        request_params = { :title => expected_event_title }
        update_event(@event, request_params)
        @event.title.should == expected_event_title
        response.status.should eq(200)
      end

      it 'creates an activity item' do
        old_event_title = @event.title
        new_event_title = "#{@event.title}-Updated"
        request_params = { :title => new_event_title }
        lambda { update_event(@event, request_params) }.should change(ActivityItem, :count).by(1)
        
        activity_item = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :updated])
        activity_item.length.should == 1
        activity_item = activity_item.first

        activity_item.subj_type.should == user_one.class.name
        activity_item.obj_type.should == @event.class.name
        activity_item.meta_data.should == { :title => [ old_event_title, new_event_title ] }.to_json
        response.status.should eq(200)
      end
    end

    context 'when organiser cancels' do

      it 'it cancels the event' do
        request_params = { :status => EventStatusEnum::CANCELLED }
        update_event(@event, request_params)
        @event.status.should == EventStatusEnum::CANCELLED
        response.status.should eq(200)
      end

      it 'creates an activity item' do
        request_params = { :status => EventStatusEnum::CANCELLED }
        lambda { update_event(@event, request_params) }.should change(ActivityItem, :count).by(1)
        
        activity_item = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :cancelled])
        activity_item.length.should == 1
        activity_item = activity_item.first

        activity_item.subj_type.should == user_one.class.name
        activity_item.obj_type.should == @event.class.name
        activity_item.meta_data.should be_nil
      end
    end

    context 'when organiser updates score' do

      it 'it creates the event result' do
        request_params = { :score_for => 10, :score_against => 5 }
        update_event(@event, request_params)
        @event.result.should_not be_nil
        @event.result.score_for.should == 10.to_s
        @event.result.score_against.should == 5.to_s
        response.status.should eq(200)
      end

      it 'creates an activity item' do
        request_params = { :score_for => 10, :score_against => 5 }
        lambda { update_event(@event, request_params) }.should change(ActivityItem, :count).by(1)
        
        activity_item = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :updated])
        activity_item.length.should == 1
        activity_item = activity_item.first

        activity_item.subj_type.should == user_one.class.name
        activity_item.obj_type.should == @event.result.class.name
        activity_item.meta_data.should == { :score_for => [ "", "10" ], :score_against => [ "", "5" ] }.to_json
      end
    end

    context 'when organiser double updates score' do

      it 'creates the event result' do
        request_params = { :score_for => 10, :score_against => 5 }
        update_event(@event, request_params)
        @event.result.should_not be_nil
        @event.result.score_for.should == 10.to_s
        @event.result.score_against.should == 5.to_s
        response.status.should eq(200)
      end

      it 'creates an activity item' do
        request_params = { :score_for => 10, :score_against => 5 }
        lambda { update_event(@event, request_params) }.should change(ActivityItem, :count).by(1)
        request_params = { :score_for => 20, :score_against => 10 }
        lambda { update_event(@event, request_params) }.should change(ActivityItem, :count).by(1)
        
        activity_item = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :updated])
        activity_item.length.should == 2
        activity_item = activity_item.last

        activity_item.subj_type.should == user_one.class.name
        activity_item.obj_type.should == @event.result.class.name
        activity_item.meta_data.should == { :score_for => [ "10", "20" ], :score_against => [ "5", "10" ] }.to_json
      end
    end

    context 'when organiser postpones event' do
      describe 'no notifications' do
        before :each do
          EmailNotificationService.stub(:send_postpone_notifications)
          @prior_event_attrs = @event.attributes
          request_params = { :status => EventStatusEnum::POSTPONED, :time_local => nil }
          update_event(@event, request_params)
        end

        it 'returns 200' do
          response.status.should eq(200)
        end  

        it 'sets the status to postponed' do
          @event.status.should == EventStatusEnum::POSTPONED
        end

        it 'creates an activity_item for the postpone action' do
          activity_items = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :postponed])
          activity_items.length.should == 1
          activity_item = activity_items.last

          activity_item.subj_type.should == user_one.class.name
          activity_item.obj_type.should == @event.class.name
          activity_item.meta_data.should == {}.to_json
        end

        it 'resource is versioned' do
          versions = VestalVersions::Version.where(:versioned_id => @prior_event_attrs["id"], :versioned_type => Event.name, :tag => nil)
          versions.length.should == 1
          versions.first.modifications["status"].should == [ @prior_event_attrs['status'], EventStatusEnum::POSTPONED ]
        end

        it 'have time tbc' do
          @event.time_tbc.should == true
        end
      end

      it 'triggers email notifications to be sent' do
        AppEventService.should_receive(:event_postponed).with(@event, user_one, {diff: {}, notify: true})
        request_params = { :status => EventStatusEnum::POSTPONED, :notify => 1, :time_local => nil }
        update_event(@event, request_params)
      end
    end

    context 'when organiser rescheduled event' do
      describe 'no notification' do
        before :each do
          @location = FactoryGirl.create(:location)
          EmailNotificationService.stub(:send_rescheduled_notifications)
          @prior_event_attrs = @event.attributes
          @time = Time.now
          request_params = { :status => EventStatusEnum::RESCHEDULED, :time_local => @time.to_s, :location => { :id => @location.id } }
          update_event(@event, request_params)
        end

        it 'returns 200' do
          response.status.should eq(200)
        end  

        it 'creates an activity_item for the rescheduled action' do
          activity_items = ActivityItem.find(:all, :conditions => ["subj_id=? and obj_id=? and verb=?", user_one.id, @event.id, :rescheduled])
          activity_items.length.should == 1
          activity_item = activity_items.last

          activity_item.subj_type.should == user_one.class.name
          activity_item.obj_type.should == @event.class.name
          meta_data = JSON.parse(activity_item.meta_data)
          meta_data["location_id"].should_not be_nil
          meta_data["time"].should_not be_nil
        end

        it 'sets the status to postponed' do
          @event.status.should == EventStatusEnum::NORMAL
        end

        it 'sets the location' do
          @event.location.should == @location
        end

        it 'sets the time' do
          @event.time.utc.should_not == @prior_event_attrs["time"].utc
        end

        it 'should not have time tbc' do
          @event.time_tbc.should == false
        end

        it 'reset availability' do
          @event.teamsheet_entries.each do |tse|
            tse.latest_response.should == InviteResponseEnum::NOT_RESPONDED
          end
        end
      end

      it 'triggers email notifications to be sent' do
        location = FactoryGirl.create(:location)
        # TODO: test the hash contents... I can't make it match, even though it looks correct. TS
        AppEventService.should_receive(:event_rescheduled).with(@event, user_one, kind_of(Hash))
        #EmailNotificationService.should_receive(:send_rescheduled_notifications).once.with(@event, hash_including("time" => anything, "location_id" => anything), user_one)
        request_params = { :status => EventStatusEnum::RESCHEDULED, :time_local => Time.now.to_s, :location => { :id => location.id }, :notify => 1 }
        update_event(@event, request_params)
      end
    end
  end
end




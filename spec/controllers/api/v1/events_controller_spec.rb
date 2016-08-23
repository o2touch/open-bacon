require 'spec_helper'

describe Api::V1::EventsController do
  render_views
	let(:user_one){ FactoryGirl.create(:user, :with_team_events, team_count: 1, team_event_count: 3, team_past_event_count: 2) }
  let(:user_two){ FactoryGirl.create(:user, :with_team_events, team_count: 1, team_event_count: 2, team_past_event_count: 1) }
	let(:team_one) do
    # do this first, so the team gets created to add the players to
    team_one = user_one.teams_as_organiser.first

    # add a few players
    player_one = FactoryGirl.create(:user)
    TeamUsersService.add_player(team_one, player_one, false)
    player_two = FactoryGirl.create(:user)
    TeamUsersService.add_player(team_one, player_two, false)
    player_three = FactoryGirl.create(:user)
    TeamUsersService.add_player(team_one, player_three, false)
    
    team_one
  end
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
    EventInvitesService.stub(add_players: true)
    TeamEventsService.stub(add: true)
    EventNotificationService.stub(send_invitations: true)
    FacebookService.stub(post_organise_game_action: true)
    request.env['X-AUTH-TOKEN'] = user_one.authentication_token
    AppEventService.stub(:create)
  end


  describe '#index', type: :api do
    context 'when no params passed' do 
  		it 'should error' do
        get :index, format: :json
  			response.status.should eq(422)
  		end
  	end

  	context 'when team param is passed' do
      context 'with a valid request' do
        before :each do 
          get :index, format: :json, team_id: team_one.id
        end

        it 'is successful', :sidekiq => false  do
          response.status.should eq(200)
        end

        it 'returns all events for team' do
          JSON.parse(response.body).count.should eq 5
        end

        it 'returns only events for team' do
          JSON.parse(response.body).each do |event|
            event.fetch("team")['id'].should eq(team_one.id)
          end
        end
      end

      context 'with an invalid request' do
        it 'responds with 422' do
          get :index, format: :json, team_id: -1
          response.status.should eq 422
        end
      end

      context 'with future event time filter' do
        it 'should be successful' do
          team_one.should_receive(:future_events).and_return([])
          Team.should_receive(:find_by_id).and_return(team_one)
          get :index, format: :json, team_id: team_one.id, when: 'future' 
          response.status.should eq 200
        end
      end

      context 'with future event time filter' do
        it 'should be successful' do
          team_one.should_receive(:future_events).and_return([])
          Team.should_receive(:find_by_id).and_return(team_one)
          get :index, format: :json, team_id: team_one.id, when: 'future' 
          response.status.should eq 200
        end
      end

      context 'with nil event time filter' do
        it 'should be successful' do
          team_one.should_receive(:events).and_return([])
          Team.should_receive(:find_by_id).and_return(team_one)
          get :index, format: :json, team_id: team_one.id, when: 'past' 
          response.status.should eq 200
        end
      end
	  end

    context 'with bad event time filter' do
      it 'should not be successful' do
        get :index, format: :json, team_id: team_one.id, when: 'unknown time filter' 
        response.status.should eq 422
      end
    end

    context 'when user param is passed' do
      context 'with a valid request' do
        it 'is successful' do
          @user = FactoryGirl.build_stubbed(:user, profile: nil)
          @user.stub(:id).and_return(1)
          @user.should_receive(:events).and_return([])
          @user.should_receive(:events_last_updated_at).and_return(Time.now)
          User.should_receive(:find_by_id).with(1).and_return(@user)
          get :index, format: :json, user_id: @user.id
          response.status.should eq(200)
        end
      end

      context 'with an invalid request' do
        it 'responds with 422' do
          get :index, format: :json, user_id: -1
          response.status.should eq 422
        end
      end

      context 'filtering' do 
        before :each do
          @user = FactoryGirl.build_stubbed(:user, profile: nil)
          @user.stub(:id).and_return(1)
          @user.should_receive(:events_last_updated_at).and_return(Time.now)
          User.should_receive(:find_by_id).with(1).and_return(@user)
        end
      
        context 'with future event time filter' do
          it 'should be successful' do
            @user.should_receive(:future_events).and_return([])
            get :index, format: :json, user_id: @user.id, when: 'future' 
            response.status.should eq 200
          end
        end

        context 'with past event time filter' do
          it 'should be successful' do
            @user.should_receive(:past_events).and_return([])
            get :index, format: :json, user_id: @user.id, when: 'past' 
            response.status.should eq 200
          end
        end

        context 'with nil event time filter' do
          it 'should be successful' do
            @user.should_receive(:events).and_return([])
            get :index, format: :json, user_id: @user.id 
            response.status.should eq 200
          end
        end
      end
    end

	  context 'when user, team and period params are passed' do
      # given the above tests I'm willing to test just one combination...

      before :each do
        @user = FactoryGirl.build_stubbed(:user, profile: nil)
        @user.stub(:id).and_return(1)
        User.should_receive(:find_by_id).and_return(@user)
        @user.stub(:events_last_updated_at).and_return(Time.now)
      end

      it 'should return events for the specified user' do
        @user.should_receive(:future_events).and_return([])
        get :index, format: :json, user_id: 1, team_id: 1, when: "future"
        response.status.should eq(200)
      end
	  end
  end

  describe '#show', type: :api do
    context 'when owner' do
      before :each do
        get :show, format: :json, id: team_one.events.first.id
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'returns that event' do
        JSON.parse(response.body).fetch("id").should == team_one.events.first.id
      end

      it 'returns the open_invite_link' do
        JSON.parse(response.body).fetch("open_invite_link").should == team_one.events.first.open_invite_link
      end
    end

    context 'when a player' do
      before :each do
        request.env['X-AUTH-TOKEN'] = player_one.authentication_token
        get :show, format: :json, id: team_one.events.first.id
      end
      it 'is successful' do
        response.status.should eq(200)
      end

      it 'returns that event' do
        JSON.parse(response.body).fetch("id").should == team_one.events.first.id
      end

      it 'does not return the open_invite_link' do
        JSON.parse(response.body).has_key?("open_invite_link").should == false
      end
    end

    context 'when unauthorized' do 
      before :each do 
        get :show, format: :json, id: team_two.events.first.id
      end

      it 'returns 200 unauthorized (events are public)' do
        response.status.should eq(200)
      end
    end
  end

  describe '#create' do
    before :each do
      fake_ability
      @user = FactoryGirl.create(:user, profile: nil)
      signed_in(@user)
      controller.should_receive(:current_user).and_return(@user)

      @event_attrs = FactoryGirl.attributes_for(:event, user: @user)
      # otherwise Event.time_local= gets all mental.
      @event_attrs[:time_local] = 1.week.from_now.to_s
      @event_attrs[:status] = EventStatusEnum::NORMAL
      @event_attrs[:team_id] = 1
    end
    def do_create(event_attrs, notify=false)
      notify_attr = notify ? 1 : 0
      reset_emails
      post :create, format: :json, event: event_attrs, notify: notify_attr
    end

    context 'authorization is performed' do
      it '401 when unauthorized' do
        mock_ability(create: :fail)

        do_create @event_attrs
        response.status.should eq(401)
      end

      it '200 when authorized' do
        # mock_ability(create: :pass)
        # mock_ability(manage: :pass)
        # SR - The above causes a failure because rspec does not record multiple calls.
        do_create @event_attrs
        response.status.should eq(200)
      end
    end

    context 'authentication' do 
      it 'is performed' do
        signed_out
        do_create @event_attrs
        response.status.should eq(401)
      end
    end

    context 'when valid request' do

      it 'creates the resource' do
        lambda { do_create @event_attrs }.should change(Event, :count).by(1)
      end

      context 'when team_id param is passed' do
        before :each do
          @event_attrs[:team_id] = 1

          # create some players, and shit.
          #player_one
          @team = double("team")
          @team.stub(players: [])
          Team.stub(find: @team)
          @team.stub(goals: GoalChecklist.new)
        end

        it '401 when unauthorized' do
          mock_ability(create: :pass, manage: :fail)

          do_create @event_attrs
          response.status.should eq(401)
        end

        it '200 when authorized' do
          mock_ability(create: :pass, manage: :pass)
          
          do_create @event_attrs
          response.status.should eq(200)
        end

        it 'creates the resource' do
          lambda { do_create @event_attrs }.should change(Event, :count).by(1)
        end

        it 'associates resource with team' do
          TeamEventsService.should_receive(:add).with(@team, kind_of(Event), true, false)
          do_create @event_attrs
        end

        it 'sets the time_zone to that of the user' do
          do_create @event_attrs
          Event.last.time_zone.should eq(@user.time_zone)
        end

        context 'notify param' do
          context 'when passed as 1' do
            it 'sends out invitations' do
              AppEventService.should_receive(:event_created).with(kind_of(Event), @user, {notify: true})
              do_create(@event_attrs, true)
            end
          end

          context 'when passed as 0' do
            it 'does not sends invitations' do
              # we now force this to be true. TS
              AppEventService.should_receive(:event_created).with(kind_of(Event), @user, {notify: true})
              do_create(@event_attrs, false)
            end
          end
        end

        it 'creates a new location if no id' do
          loc_attrs = { location: {
              address: "353 E Bonneville Ave",
              lat: "1.0",
              lng: "1.0",
              title: "tim's house"
            },
            team_id: 1
          }
          Location.should_receive(:create!).with(loc_attrs[:location]).and_call_original
          do_create(@event_attrs.merge(loc_attrs))
        end

        it 'does not create a new location if id' do
          loc_attrs = { location: {
              id: 1,
              address: "353 E Bonneville Ave",
              lat: "1.0",
              lng: "1.0",
              title: "tim's house"
            },
            team_id: 1
          }
          Location.should_not_receive(:create!)
          do_create(@event_attrs.merge(loc_attrs))
        end
      end
    end

    context 'when invalid request' do
      it 'returns error when no team_id passed' do
        @event_attrs[:team_id] = nil
        do_create @event_attrs
        response.status.should eq(422)
      end
      it 'returns error' do
        do_create ""
        response.status.should eq(422)
      end
    end
  end

  describe '#update', type: :api do
    def do_update(attrs={}, notify=nil)
      @title = "TIM IS AMAZING!!!!1! ZOMG."
      @event = team_one.events.first 
      event_attrs = @event.attributes
      event_attrs["location"] = @event.location.attributes
      event_attrs.merge! attrs
      event_attrs["title"] = @title
      reset_emails
      put :update, format: :json, id: event_attrs["id"], event: event_attrs, notify: notify
      event_attrs
    end

    context 'when owner' do
      it 'it responds with 200' do
        do_update
        response.status.should eq(200)
      end

      it 'resource is updated' do
        do_update
        team_one.events.first.reload
        team_one.events.first.title.should eq(@title)
      end

      it 'does not send any emails' do
        do_update
        last_emails.count.should eq(0)
      end

      it 'updates last_edited' do
        do_update
        event = team_one.events.first
        event.reload
        event.last_edited.should_not == nil
      end

      it 'creates a new location if no id' do
        loc_attrs = { location: {
            address: "353 E Bonneville Ave",
            lat: "1.0",
            lng: "1.0",
            title: "tim's house"
          }
        }
        Location.should_receive(:create!).with(loc_attrs[:location]).and_call_original
        do_update(loc_attrs)
      end

      it 'does not create a new location if id' do
        loc_attrs = { location: {
            id: 1,
            address: "353 E Bonneville Ave",
            lat: "1.0",
            lng: "1.0",
            title: "tim's house"
          }
        }
        Location.should_not_receive(:create!)
        do_update(loc_attrs)
        @event.location_id.should eq(1)
      end

      it 'sets location to nil if location == nil' do
        @location = FactoryGirl.create :location
        team_one.events.first.update_attribute(:location, @location)
        attrs = team_one.events.first.attributes
        attrs[:location] = nil
        do_update(attrs)
        @event.reload
        @event.location.should eq(nil)
      end

      it 'leaves the location the same if we receive do not receive a location key' do
        @location = FactoryGirl.create :location
        team_one.events.first.update_attribute(:location, @location)
        attrs = team_one.events.first.attributes
        attrs.delete :location
        do_update(attrs)
        @event.reload
        @event.location.should eq(@location)
      end

      context 'when cancelling an event' do
        it 'does not sent any emails' do
          do_update({ "status" => EventStatusEnum::CANCELLED })
          last_emails.count.should eq(0)
        end
      end

      # context 'when postponing an event surpressing notifications' do
      #   it 'does not call notification service' do
      #     do_update({ "status" => EventStatusEnum::POSTPONED }, 0)
      #     EmailNotificationService.should_not_receive(:send_postpone_notifications)
      #   end
      # end

      # context 'when postponing an event triggering notifications' do
      #   it 'does call notification service' do
      #     do_update({ "status" => EventStatusEnum::POSTPONED}, 1)
      #     EmailNotificationService.should_receive(:send_postpone_notifications).once
      #   end
      # end

      # context 'when rescheduling an event surpressing notifications' do
      #   it 'does not call notification service' do
      #     do_update({ "status" => EventStatusEnum::RESCHEDULED }, 0)
      #     EmailNotificationService.should_not_receive(:send_rescheduled_notifications)
      #     EmailNotificationService.should_not_receive(:send_postpone_notifications)
      #   end
      # end

      # context 'when rescheduling an event triggering notifications' do
      #   it 'does call notification service' do
      #     do_update({ "status" => EventStatusEnum::RESCHEDULED }, 1)
      #     EmailNotificationService.should_receive(:send_rescheduled_notifications).once
      #     EmailNotificationService.should_not_receive(:send_postpone_notifications)
      #   end
      # end

      it 'resource is versioned' do
        event_attrs = team_one.events.first.attributes
        update_event_attrs = do_update
        versions = VestalVersions::Version.where(:versioned_id => event_attrs["id"], :versioned_type => "Event", :tag => nil)
        versions.length.should == 1
        versions.first.modifications["title"].should == [ event_attrs['title'], update_event_attrs['title'] ]
      end
    end

    context 'when team member' do
      it 'responds with 401' do
        request.env['X-AUTH-TOKEN'] = player_one.authentication_token

        do_update
        response.status.should eq(401)
      end
    end

    context 'when logged out' do
      it 'responds with 401' do
        request.env['X-AUTH-TOKEN'] = nil
        do_update
        response.status.should eq(401)
      end
    end
  end

  describe '#destroy', type: :api do
    def do_destroy
      reset_emails
      delete :destroy, id: team_one.events.first.id
    end

    context 'when owner' do
      it 'it responds with 204' do
        do_destroy
        response.status.should eq(204)
      end

      it 'resource is deleted' do
        event_attrs = team_one.events.first.attributes
        lambda { do_destroy }.should change(team_one.events, :count).by(-1)
        expect { Event.find(event_attrs.id) }.to raise_error
      end

      it 'resource is versioned with delete tag' do
        event_attrs = team_one.events.first.attributes
        do_destroy
        versions = VestalVersions::Version.where(:versioned_id => event_attrs["id"], :versioned_type => "Event", :tag => "deleted")
        versions.length.should == 1
        versions.first.modifications.should == event_attrs
      end

      it 'does not sent any emails' do
        do_destroy
        last_emails.count.should eq(0)
      end
    end

    context 'when member' do
      it 'responds with 401' do
        request.env['X-AUTH-TOKEN'] = player_one.authentication_token

        do_destroy
        response.status.should eq(401)
      end
    end

    context 'when logged out' do
      it 'responds with 401' do
        request.env['X-AUTH-TOKEN'] = nil

        do_destroy
        response.status.should eq(401)
      end
    end
  end
end

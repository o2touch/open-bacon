require 'spec_helper'

describe Api::V1::InviteResponsesController, :type => :controller do

  describe "updaing a teamsheet entry using teamsheet_entry_id" do
    login_team_organiser(team_count=1, team_event_count=1)

    before do
      @organiser = subject.current_user
      @event = @organiser.future_events.first
      @tse = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @organiser)
      @event.teamsheet_entries(true)

      params = {    
        :response_status => InviteResponseEnum::AVAILABLE,
        :tse_id => @tse
      }

      post :create, params, :format => 'json'
      @tse.reload
    end

    it 'updates the teamsheet entry' do
      @tse.response_status.should == InviteResponseEnum::AVAILABLE
    end
    
    it 'returns success' do
      response.header['Content-Type'].should include 'json'
      response.status.should == 201
    end
  end
  
  describe "updaing a teamsheet entry using event_id and user_id" do
    login_team_organiser(team_count=1, team_event_count=1)

    before do
      @organiser = subject.current_user
      @event = @organiser.future_events.first
      @tse = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @organiser)
      @event.teamsheet_entries(true)

      params = {    
        :response_status => InviteResponseEnum::UNAVAILABLE,
        :event_id => @event.id,
        :user_id => @organiser.id,
      }

      post :create, params, :format => 'json'
      @tse.reload
    end

    it 'updates the teamsheet entry' do
      @tse.response_status.should == InviteResponseEnum::UNAVAILABLE
    end
    
    it 'returns success' do
      response.header['Content-Type'].should include 'json'
      response.status.should == 201
    end
  end

   describe "updaing a teamsheet entry as a player" do
    login_user

    before(:each) do
      @organiser = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 1, :team_past_event_count => 0)
      @event = @organiser.future_events.first
      @team = @event.team
      @invitee = subject.current_user
      @team.add_player(@invitee)
      @tse = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invitee)
      @event.teamsheet_entries(true)

      params = {    
          :response_status => InviteResponseEnum::AVAILABLE,
          :event_id => @event.id,
          :user_id => @invitee.id,
      }

      post :create, params, :format => 'json'
      @tse.reload
    end

    it 'updates the teamsheet entry' do
      @tse.response_status.should == InviteResponseEnum::AVAILABLE
    end

    it 'returns success' do
      response.header['Content-Type'].should include 'json'
      response.status.should == 201
    end
  end
end
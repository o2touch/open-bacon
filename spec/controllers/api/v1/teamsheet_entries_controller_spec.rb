require 'spec_helper'

describe Api::V1::TeamsheetEntriesController do
  render_views

  before :each do
  	@team = FactoryGirl.create(:team, :with_players, :with_events, event_count: 1)
  	@event = @team.events.first
  	@team.players.each do |player|
  		FactoryGirl.create(:teamsheet_entry, event: @event, user: player)
  	end

    request.env['X-AUTH-TOKEN'] = @team.created_by.authentication_token
  end

  describe '#index', type: :api do
  	context 'when authorized' do
  		before :each do
  			get :index, format: :json, id: @event.id
  		end

  		it 'is returns success' do
  			response.status.should eq 200
  		end

  		it 'returns all teamsheet entries' do
  			JSON.parse(response.body).count.should eq 12
  		end

  		it 'returns only teamsheet entries for that event' do
  			JSON.parse(response.body).each do |entry|
  				entry.fetch("event_id").should eq @event.id
  			end
  		end
  	end
  end

  describe '#create', type: :api do
    context 'when valid request' do
      context 'when event is open invite' do
        it 'creates a new resource'
      end

      # Note: This is not implemented in the existing teamsheet_entries_controller, anyone is able to create a teamsheet_entry on an event
      context 'when event is closed invite' do
        context 'when owner' do
          it 'creates an new resource'
        end

        # When member of this event, should not be able to add players
        context 'when member' do
          it 'responds with 401 (unauthorized)'
          it 'does not create the resource'
        end

        context 'when logged-out' do
          it 'responds with 401 (unauthorized)'
          it 'does not create the resource'
        end
      end

    end

    context 'when invalid request' do

    end
  end

  describe '#show', type: :api do
    it 'responds with 502'
  end

  describe '#update', type: :api do
    it 'responds with 502'
  end

  describe '#destroy', type: :api do
    context 'when owner' do
      it 'destroys resource'
    end

    context 'when member' do
      it 'responds with 401 (unauthorized)'
      it 'does not destroy the resource'
    end

    context 'when logged-out' do
      it 'responds with 401 (unauthorized)'
      it 'does not destroy the resource'
    end    
  end
end
require 'spec_helper'

describe Api::V1::InviteRemindersController, :type => :controller  do
  render_views

  let(:user_one){ FactoryGirl.create(:user, :with_team_events, team_count: 1, team_event_count: 3, team_past_event_count: 0) }
  let(:team) do
    # do this first, so the team gets created to add the players to
    team = user_one.teams_as_organiser.first
    # add a few players
      player_one = FactoryGirl.create(:user)
      TeamUsersService.add_player(team, player_one, false, nil, false)
      player_two = FactoryGirl.create(:user)
      TeamUsersService.add_player(team, player_two, false, nil, false)
      player_three = FactoryGirl.create(:user)
      TeamUsersService.add_player(team, player_three, false, nil, false)
    
    
    team
  end

  before :each do
    request.env['X-AUTH-TOKEN'] = user_one.authentication_token
  end

  context '#create' do
    def do_create
    reset_emails
      post :create, format: :json, invite_reminder: { event_id: team.future_events.first.id }
    end

    it 'returns success' do
      do_create
      response.status.should eq(200)
    end

    it 'creates and app_event' do
      AppEventService.should_receive(:create).with(kind_of(Event), kind_of(User), :invite_reminder, {})
      do_create
    end
  end
end
require 'spec_helper'
require 'set'

include EventJsonHelper

describe "Event JSON Helper" do 

  before do
    @organiser = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 30, :team_past_event_count => 30)
    @team = @organiser.teams.first
    15.times do
      TeamUsersService.add_player(@team, FactoryGirl.create(:user), false, nil)
    end
    @player = @team.players.last
  end

  describe "Rendering 60 events with 15 players invited" do

    context 'for a given player' do

     it "returns a collection of events in json format with the correct user permissions assigned per event", performance: true do
        runs = 10
        accumulative_time = 0
        runs.times do
          accumulative_time += time do
             json_collection(@team.events, @player)
          end
        end

        (accumulative_time/runs).should be < 0.8

        ability = Ability.new(@player)
        children = Set.new

        runs = 10
        accumulative_time = 0
        runs.times do
          accumulative_time += time do
            event_data(@team.future_events.first, @player, ability, children)
          end
        end
        (accumulative_time/runs).should be < 0.1
      end
    end
  end
end
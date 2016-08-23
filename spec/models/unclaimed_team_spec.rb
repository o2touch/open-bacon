require 'spec_helper'

describe UnclaimedTeam do
  it "factory is valid" do
    team = FactoryGirl.create(:unclaimed_team)
    team.should be_a UnclaimedTeam
    team.should be_valid
    team.profile.should be_valid
    team.associates.should be_empty
    team.organisers.should be_empty
    team.players.should be_empty
    team.parents.should be_empty
    team.followers.should be_empty
    team.events.should be_empty
    team.founder.should be_nil
  end

  it 'raises an error if players are added' do
    team = FactoryGirl.create(:unclaimed_team)
    expect { team.add_player(double('user')) }.to raise_error
    expect { team.add_parent(double('user')) }.to raise_error
    expect { team.add_organiser(double('user')) }.to raise_error
  end

  it 'allows users to follow the team' do
    team = FactoryGirl.create(:unclaimed_team)
    follower = FactoryGirl.create(:user)
    team.add_follower(follower)
    team.followers.should have_exactly(1).items
    team.followers.should include follower
  end

  
end

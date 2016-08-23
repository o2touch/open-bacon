require 'spec_helper'

describe Team do

  context 'team factory' do
    it "is valid" do
      team = FactoryGirl.create(:team)
      team.should be_valid
      team.profile.should be_valid
      team.players.should have_exactly(1).items
      team.organisers.should have_exactly(1).items
      team.events.should be_empty
    end
  end

  context 'adding an existing player to a team which has a founder' do
    it 'does not create a player team role' do
      organiser = FactoryGirl.create(:user)
      player = FactoryGirl.create(:user)
      team = FactoryGirl.create(:team, :created_by => organiser)

      5.times do |i|
        team.add_player(player) 
      end

      PolyRole.find(:all, :conditions => { :role_id => PolyRole::PLAYER, :user_id => player.id, :obj_type => 'Team', :obj_id => team.id }).length.should == 1
      team.has_member?(player).should be_true
    end
  end

  context 'adding a player to a team which has a founder' do
    it 'creates a player team role' do
      organiser = FactoryGirl.create(:user)
      player = FactoryGirl.create(:user)
      team = FactoryGirl.create(:team, :created_by => organiser)
      TeamUsersService.add_player(team, player, false)

      PolyRole.exists?(:role_id => PolyRole::PLAYER, :user_id => player.id, :obj_type => 'Team', :obj_id => team.id).should be_true
      team.has_member?(player).should be_true
    end
  end

  context 'adding an organiser to a team which has no founder' do
    before :each do
      @organiser = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:team, :created_by => nil)
      TeamUsersService.add_organiser(@team, @organiser)
    end

    it 'creates a organiser team role' do
      PolyRole.exists?(:role_id => PolyRole::ORGANISER, :user_id => @organiser.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
      @team.has_member?(@organiser).should be_true
    end

    it 'creates a player team role' do
      PolyRole.exists?(:role_id => PolyRole::PLAYER, :user_id => @organiser.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
    end

    it 'sets the organiser as the team founder' do
      @team.founder.should == @organiser
    end
  end

  context 'adding an organiser who is a follower of a faft team' do
    before :each do
      @follower = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:team, :created_by => nil)
      @team.stub(:faft_team?).and_return(true)
      @team.add_follower(@follower)
    end

    it 'creates a organiser team role' do
      TeamUsersService.add_organiser(@team, @follower)
      PolyRole.exists?(:role_id => PolyRole::ORGANISER, :user_id => @follower.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
      @team.has_organiser?(@follower).should be_true
    end

    it 'remove a follower team role' do
      TeamUsersService.add_organiser(@team, @follower)
      PolyRole.exists?(:role_id => PolyRole::FOLLOWER, :user_id => @follower.id, :obj_type => 'Team', :obj_id => @team.id).should be_false
    end

    it 'should error if the user is organising to many faft teams' do
      @follower.stub(:faft_teams_as_organiser).and_return(MAX_FAFT_TEAMS_ORGANISING)
      expect { TeamUsersService.add_organiser(@team, @follower) }.to raise_error
    end
  end

  context 'adding an organiser to a team which has a founder' do
    before :each do
      founder = FactoryGirl.create(:user)
      @organiser = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:team, :created_by => founder)
      TeamUsersService.add_organiser(@team, @organiser)
    end

    it 'creates a organiser team role' do
      PolyRole.exists?(:role_id => PolyRole::ORGANISER, :user_id => @organiser.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
      @team.has_member?(@organiser).should be_true
    end

    it 'creates a player team role' do
      PolyRole.exists?(:role_id => PolyRole::PLAYER, :user_id => @organiser.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
    end
  end

  context 'adding an organiser to a junior team' do
    before :each do
      founder = FactoryGirl.create(:user)
      @organiser = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:junior_team, :created_by => founder)
      TeamUsersService.add_organiser(@team, @organiser)
    end

    it 'creates a organiser team role' do
      PolyRole.exists?(:role_id => PolyRole::ORGANISER, :user_id => @organiser.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
      @team.has_member?(@organiser).should be_true
    end

    it 'does not creates a player team role' do
      PolyRole.exists?(:role_id => PolyRole::PLAYER, :user_id => @organiser.id, :obj_type => 'Team', :obj_id => @team.id).should be_false
    end
  end

  context 'adding a follower to a team' do
    before :each do
      @follower = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:team)
    end

    it 'creates a follower team role' do
      TeamUsersService.add_follower(@team, @follower)
      PolyRole.exists?(:role_id => PolyRole::FOLLOWER, :user_id => @follower.id, :obj_type => 'Team', :obj_id => @team.id).should be_true
    end

    it 'should raise error if a user is being made a follower of a team they are already a member of' do
      @team.add_follower(@follower)
      expect { TeamUsersService.add_follower(@team, @follower) }.to raise_error
      expect { TeamUsersService.add_follower(@team, @team.organisers.first) }.to raise_error
      expect { TeamUsersService.add_follower(@team, @team.players.first) }.to raise_error
    end
  end

  describe '#members' do
    before :each do
      @team = FactoryGirl.create(:junior_team)
      junior = FactoryGirl.create(:junior_user)
      @team.add_player(junior)
      @team.add_parent(junior.parents.first)
    end
    it 'should return a list of user who have roles on this team' do
      @team.reload
      @team.members.count.should eq(3) # organiser, player, parent
    end
  end

  describe '#league_config' do
    before :each do
      organiser = FactoryGirl.create(:user)
      @division = FactoryGirl.create(:division_season)
      @league = @division.league
      @team = FactoryGirl.create(:team, :created_by => organiser)
      TeamDSService.add_team(@division, @team)
      @team.reload
    end
    
    it 'returns the league settings if no settings are defined on the team' do
      @team.settings.should == {}
      @team.league_config.should == @league.league_config
    end

    it 'returns an empty hash if the team is not affiliated with a division' do
      @team.settings.should == {}
      TeamDSService.remove_team(@team.divisions.first, @team)
      @team.league_config.should == {}
    end

    it 'returns an empty hash if the team is not affiliated with a division regardless of any data in the settings hash' do
      @team.settings = { "Noel" => "Teenage Dirt Bag" }
      TeamDSService.remove_team(@team.divisions.first, @team)
      @team.league_config.should == {}
    end

    it 'returns merged league settings and team settings if settings are defined on the team' do
      @team.settings = { 
        LeagueConfigKeyEnum::KEY => {
          @division.id.to_s => {
            LeagueConfigKeyEnum::PUBLIC_TEAM_PROFILES => false,        
            LeagueConfigKeyEnum::MANAGE_RESPONSES => false,
            "Random Key" => true
          }
        }
      }

      @team.league_config.should == {
        LeagueConfigKeyEnum::PUBLIC_TEAM_PROFILES => false,
        LeagueConfigKeyEnum::ORGANISER_CAN_CREATE_EVENTS => true,
        LeagueConfigKeyEnum::NOTIFY_UNAVAILABLE_PLAYERS => true,
        LeagueConfigKeyEnum::MANAGE_RESPONSES => false,
        LeagueConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => [1, 3],
        LeagueConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR => 13,
        LeagueConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE => 0,
        LeagueConfigKeyEnum::LEAGUE_MANAGED_ROSTER => false,
        "Random Key" => true
      }
    end

    describe '#league_managed_roster?', :broken => true do
      it 'should return nil if the team is not in a league' do
        @t = FactoryGirl.build :team
        @t.league_managed_roster?.should be_false
      end
      it 'should return false if the roster is not league-managed' do
        @team.league_managed_roster?.should be_false
      end
      it 'should return true if the roster is league-managed' do
        @team.league_config
        @team.settings["league_config"][@team.divisions.first.id.to_s][LeagueConfigKeyEnum::LEAGUE_MANAGED_ROSTER] = true
        @team.league_managed_roster?.should be_true
      end
    end
  end

  describe '#user_is_primary_league_admin?' do
    before :each do
      @league = FactoryGirl.create :league
      @div = FactoryGirl.create :division_season
      @org = @div.league.organisers.first
      @team = FactoryGirl.create(:team)
      TeamDSService.add_team(@div, @team)
    end
    it 'should return false if the team is not a league' do
      @team = FactoryGirl.create :team
      @team.user_is_primary_league_admin?(@org).should be_false
    end
    it 'should return false if user is nil' do 
      @team.user_is_primary_league_admin?(nil).should be_false
    end
    it 'should call the has_organiser? on the first divisisions league' do
      @team.user_is_primary_league_admin?(@org).should be_true
    end
  end

  describe '#team_config' do
    before :each do
      organiser = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:team, :created_by => organiser)
    end

    it 'returns an empty hash if no settings are defined on the team' do
      @team.settings.should == {}
      @team.team_config.should == {}
    end

    it 'returns team setting if settings are defined on the team' do
      @team.settings = {
        TeamConfigKeyEnum::KEY => {
          TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => [1,2,3],
          "Random Key" => true
        }
      }
      @team.team_config.should == {
        TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => [1,2,3],
        "Random Key" => true
      }
    end
  end

  describe '#get_players_in_team?' do
    before :each do
      @team = FactoryGirl.create(:team, :with_players)

      @users_array = @team.players
    end
    it 'should return the players in team' do
      @team.get_players_in_team(@users_array).size.should == @users_array.size
    end
  end

  describe 'league helper methods' do
    describe 'primary_division' do
      it 'returns the first division' do
        @team = FactoryGirl.create(:team)
        primary_division = "division 1"
        divisions = [primary_division, "division 2"]
        @team.stub(:divisions).and_return(divisions)
        @team.primary_division.should == primary_division
      end

      it 'returns the null division if no divisions exist' do
        @team = FactoryGirl.create(:team)
        primary_division = "division 1"
        divisions = []
        @team.stub(:divisions).and_return(divisions)
        @team.primary_division.should be_an_instance_of NullDivision
      end
    end

    describe 'primary_league' do
      it 'returns the first divisions league' do
        @team = FactoryGirl.create(:team)
        league = "league"
        primary_division = mock_model(DivisionSeason)
        primary_division.stub(:league).and_return(league)
        divisions = [primary_division, "division 2"]
        @team.stub(:divisions).and_return(divisions)
        @team.primary_league.should == league
      end

      it 'returns the null league if no divisions exist' do
        @team = FactoryGirl.create(:team)
        primary_division = "division 1"
        divisions = []
        @team.stub(:divisions).and_return(divisions)
        @team.primary_league.should be_an_instance_of NullLeague
      end
    end

    describe 'find_by_mitoo_id' do
      it 'exists' do
        FactoryGirl.create(:team, source: "mitoo", source_id: 1234)
        expect { Team.find_by_mitoo_id(1234) }.to_not raise_error
      end
    end

  end
end

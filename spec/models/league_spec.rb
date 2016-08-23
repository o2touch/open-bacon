require 'spec_helper'

describe League do
	describe 'validations' do
		before :each do
			@league = FactoryGirl.build :league
		end

		it 'is valid when valid' do
			@league.should be_valid
		end
		it 'requires a slug' do
			@league.title = nil
			@league.slug = nil
			@league.should_not be_valid
		end
		it 'requires a slug > 2 chars' do
			@league.slug = "ti"
			@league.should_not be_valid
		end
		it 'must not have spaces' do
			@league.slug = "tim tim"
			@league.should_not be_valid
		end
		it 'must not have underscores' do
			@league.slug = "tim_tim"
			@league.should_not be_valid
		end
		it 'must not start with a hyphen' do
			@league.slug = "-timtim"
			@league.should_not be_valid
		end
		it 'requires a sport' do
			@league.sport = nil
			@league.should_not be_valid
		end
		it 'requires a sport in the SportsEnum' do
			@league.sport = "Pool Rugby"
			@league.should_not be_valid
		end
	end

	describe '#league_config' do
  	before :each do
    	@league = FactoryGirl.build :league
  	end

  	it 'returns the default league config if there are no settings on the league' do
  		@league.settings.should == {}
  		@league.league_config.should == DEFAULT_LEAGUE_CONFIG
  		@league.settings.should == { LeagueConfigKeyEnum::KEY => {} }
  	end

  	it 'returns merged league settings and team settings if settings are defined on the team' do
      @league.settings = { 
        LeagueConfigKeyEnum::KEY => {
          LeagueConfigKeyEnum::PUBLIC_TEAM_PROFILES => false,        
          LeagueConfigKeyEnum::MANAGE_RESPONSES => false,
          "Random Key" => false
        }
      }

      @league.league_config.should == {
        LeagueConfigKeyEnum::PUBLIC_TEAM_PROFILES => false,
        LeagueConfigKeyEnum::ORGANISER_CAN_CREATE_EVENTS => true,
        LeagueConfigKeyEnum::NOTIFY_UNAVAILABLE_PLAYERS => true,
        LeagueConfigKeyEnum::MANAGE_RESPONSES => false,
        LeagueConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => [1, 3],
        LeagueConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR => 13,
        LeagueConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE => 0,
        LeagueConfigKeyEnum::LEAGUE_MANAGED_ROSTER => false,
        "Random Key" => false
      }
    end
  end
end

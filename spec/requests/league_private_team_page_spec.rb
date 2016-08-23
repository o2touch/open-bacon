require 'spec_helper'

describe "leagues private team page", :js => true do

  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction

  before :each do
    league = FactoryGirl.create(:league)
    division = FactoryGirl.create(:division_season, league: league, age_group: AgeGroupEnum::ADULT)
    @team = FactoryGirl.create(:team, :with_players)
    TeamDSService.add_team(division, @team)

    # make team private
    @team.league_config[LeagueConfigKeyEnum::KEY] = {
      division.id.to_s => {
        LeagueConfigKeyEnum::PUBLIC_TEAM_PROFILES => false
      }
    }

  end

  context 'viewing the team page as LOU' do

    before :each do
      visit team_path(@team.id)
    end

    it 'shows the team profile' do
      find(".team-page-private .team-card h1").should have_content(@team.name.upcase)
    end

  end

  context 'clicking a TOIL as LOU' do

    before :each do
      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      visit power_token_path(token)
    end

    it 'shows the team profile' do
      within(".team-page-private") do
        find(".team-card").should have_content(@team.name.upcase)
        find(".signup-form form")
      end
    end

  end

  context 'viewing the team page as a player not in the team' do

    before :each do
      user = FactoryGirl.create(:user)
      as_user(user) do
        visit team_path(@team.id)
      end
    end

    it 'shows the team profile and the godbar notice' do
      find(".team-page-private .team-card").should have_content(@team.name.upcase)
      find(".godbar-new .lock")
    end

  end

end
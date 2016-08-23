module LeagueHelper

  # create a division on the given league with one fixture
  def setup_division(league, with_fixture)
    # tests use fixture titles, which currently only display if both teams are nil
    home_team = nil #FactoryGirl.create(:team, :name => "Team 1")
    away_team = nil #FactoryGirl.create(:team, :name => "Team 2")
    d = FactoryGirl.create(:division_season, league: league, age_group: AgeGroupEnum::ADULT)
    #d.teams << home_team
    if with_fixture
      f = FactoryGirl.create(:fixture, division_season: d, title: "Fixture for Division #{d.id}", time: 1.day.from_now, time_zone: TimeZoneEnum.values.sample, home_team: home_team, away_team: away_team)
    end
    u = FactoryGirl.create(:user)
    DivisionSeason.publish_edits!(d.id, u)
    d.save
    d
  end

end
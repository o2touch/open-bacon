require 'spec_helper'

include LeagueHelper

describe "League profile", :js => true do

  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction

  before :each do
    @league = FactoryGirl.create(:league)
    t = FactoryGirl.create(:team)
    d = FactoryGirl.create(:division_season, league: @league, age_group: AgeGroupEnum::ADULT, show_standings: true, track_results: true, scoring_system: "Soccer")
    TeamDSService.add_team(d, t)
    FactoryGirl.create(:fixture, division_season: d, title: "Fixture for Division #{d.id}", time: 1.day.ago, time_zone: TimeZoneEnum.values.sample, home_team: t, away_team: nil)
    u = FactoryGirl.create(:user)
    DivisionSeason.publish_edits! d.id, u.id
    d.save
  end


  # THIS SHIT NO LONGER APPLIES AS LEAGUE APP NO LONGER PUBLIC
  # context "results tab viewed as LOU" do

  #   before :each do
  #     visit league_path(@league.id)
  #     find(".content-navi-container a[name='results']").click
  #   end

  #   it "can see standings table, but not adjustments form", :broken => true do
  #     within("#r-schedule-standings") do
  #       page.should have_css("table.standings")
  #       page.should have_no_css("form.adjustement-form")
  #     end
  #   end

  #   it "can see fixture row" do
  #     within("#r-schedule-fixture-list") do
  #       page.should have_css(".fixture")
  #     end
  #   end

  #   it "can see teams panel in sidebar" do
  #     find(".sidebar-right").should have_css("#r-team-list")
  #   end

  # end


  context "results tab viewed as admin" do

    before :each do
      organiser = @league.organisers.first
      as_user(organiser) do
        visit league_path(@league.id)
      end
      find(".content-navi-container a[name='results']").click
    end

    it "can see standings table, and adjustments form", :broken => true do
      within("#r-schedule-standings") do
        page.should have_css("table.standings")
        page.should have_css("form.adjustement-form")
      end
    end
    
    it "can see fixture row" do
      within("#r-schedule-fixture-list") do
        page.should have_css(".fixture")
      end
    end

    it "can see help text panel in sidebar" do
      find(".sidebar-right").should have_css(".edit-onboarding")
    end


    context "adding an adjustment", :broken => true do

      before :each do
        @adjustment = "123"
        within("#r-schedule-standings form.adjustement-form") do
          find("input[name='desc']").set("Some description")
          find("input[name='amount']").set(@adjustment)
          find("button[name='save']").click
        end
        # wait for spinner
        #find("#r-schedule-standings .spinner-loading")
      end

      it "shows the adjustment in the standings and in the adjustments tables" do
        within("#r-schedule-standings") do
          find("table.standings").should have_content(@adjustment)
          find("table.adjustments").should have_content(@adjustment)
        end
      end

    end


    context "adding a fixture result and points" do

      before :each do
        # home team wins
        @home_score = "67"
        @away_score = "45"
        @home_points = "10"
        find("#r-schedule-fixture-list .fixture").click
        within(".results-panel") do
          find("input[name='home_score']").set(@home_score)
          find("input[name='away_score']").set(@away_score)
          find("button[name='save']").click
        end
        within(".points-panel") do
          first("input.home_points").set(@home_points)
          find("button[name='save']").click
        end
      end

      it "shows the result and points in the standings tables" , :broken => true do
        within("#r-schedule-standings table.standings") do
          find(".won").should have_content("1")
          find(".points").should have_content(@home_points)
        end
      end

      it "shows the result in the fixture row" , :broken => true do
        within("#r-schedule-fixture-list .fixture") do
          page.should have_content(@home_score)
          page.should have_content(@away_score)
        end
      end

    end

  end

end
require 'spec_helper'

include LeagueHelper

describe "As a league organiser", :js => true do

  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction

  before :each do
    @league = FactoryGirl.create(:league)
    @organiser = @league.organisers.first
  end

  context "view a league profile with division with no fixtures or teams" do

    before :each do
      FactoryGirl.create(:division_season, league: @league, age_group: AgeGroupEnum::ADULT)

      as_user(@organiser) do
        visit league_path(@league.id)
      end
    end

    it "shows empty schedule message" do
      within("#r-schedule-fixture-list") do
        page.should have_no_css(".fixture")
        page.should have_css(".page-empty")
      end
    end

    it "shows empty teams message" do
      within(".sidebar-right") do
        page.should have_no_css(".team-element")
        page.should have_css(".panel-empty")
      end
    end

    it "switch to results tab shows empty message" do
      find("a[name='results']").click

      within("#r-schedule-fixture-list") do
        page.should have_no_css(".fixture")
        page.should have_css(".page-empty")
      end
    end

  end


  context 'view a league profile' do

    before :each do
      # create 2 divisions, each with 1 fixture
      @divisions = []
      (1..2).each { @divisions << setup_division(@league, true) }

      as_user(@organiser) do
        visit league_path(@league.id)
      end
    end

    it 'changing the division updates the schedule' do
      fixture1 = @divisions.first.fixtures_to_display.first
      division2 = @divisions.second
      fixture2 = division2.fixtures_to_display.first

      within(".league-info") do
         page.should have_selector('h2', text: /#{@league.title}/i)
      end

      find(".fixtures-list").should have_content(fixture1.title)

      # then select different division to load new fixtures
      within(".division-selector") do
        find(".current-division").click
        find(".division[data-id='#{division2.id}']").click
      end
      find(".fixtures-list").should have_content(fixture2.title)
    end

    it 'changing tab works' do
      # check on schedule tab first
      fixture1 = @divisions.first.fixtures.first
      find(".fixtures-list").should have_content(fixture1.title)
      # then change tab and check empty 
      find("a[name='results']").click
      within("#r-schedule-fixture-list") do
        page.should have_no_css(".fixture")
        page.should have_css(".page-empty")
      end
    end

  end

end
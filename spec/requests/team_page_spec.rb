require 'spec_helper'

describe "viewing team profile", :js => true do

  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


  context 'as a logged in user' do

    context "for a team with no activity and no events" do
      before :each do
        organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
        team = organiser.teams_as_organiser.first

        as_user(organiser) do
          visit team_path(team.id)
        end
      end

      it "shows empty schedule message" do
        within("#r-schedule-event-list") do
          page.should have_no_css(".event-row")
          page.should have_css(".organiser-empty")
        end
      end

      it "does not show next game widget" do
        within(".new-right-sidebar") do
          # note: this div exists, but capybara ignores it because it is empty
          # and has no styling
          page.should have_no_css("#r-next-game")
          page.should have_no_css("#r-schedule-event-list")
        end
      end

      it "switch to activity tab shows empty message" do
        find("#nav-activity a").click

        within("#activity-feed") do
          page.should have_no_css(".activity-item")
          page.should have_css(".page-empty")
        end
      end

      it "switch to results tab shows empty message" do
        find("#nav-results a").click

        within("#r-team-content .main-content-results") do
          page.should have_no_css(".event-row")
          page.should have_css(".page-empty")
        end
      end
    end


    context 'for a public team' do
      before :each do
        @user = FactoryGirl.create(:user, :with_team_events)
        @team = @user.teams_as_organiser.first
        visit team_path(@team.id)
      end

      it 'does not display the activity tab' do
        page.should have_no_css("#nav-activity")
      end

    end


    context 'for a private team' do
      it 'show the private team page'
      it 'does not display the activity tab'
      it 'does not display the schedule tab'
    end
  end


  context 'as a logged-out user' do
    context 'for a private team' do
      it 'show the private team page'
      it 'does not display the activity tab'
      it 'does not display the schedule tab'
    end
  end
end
require 'spec_helper'

describe "as a logged in player user", :js => true do
  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


  context "viewing my dashboard" do

    before do
      stop_sidekiq
        @organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
        @team = @organiser.teams_as_organiser.first
        @user = FactoryGirl.create(:user)
        @team.add_player @user

        # event is required for activity items AND schedule items
        @event = FactoryGirl.create(:event, :game_type => 0, :team => @team, :user => @organiser)
        TeamEventsService.add @team, @event
        # past event is required for past events tab
        @pastEvent = FactoryGirl.create(:event, :game_type => 0, :team => @team, :user => @organiser, :time => 2.days.ago)
        TeamEventsService.add @team, @pastEvent

        as_user(@user) do
          visit user_path(@user.id)
        end
      start_sidekiq
    end

    it "see my teams" do
      within(".panel.teams") do
        page.should have_content(@team.name.upcase)
      end
    end

    it "see my activity" do
      within("#activity-feed") do
        page.should have_content(@event.title)
      end
    end

    it "see my schedule" do
      find("#nav-schedule a").click
      within(".main-content-schedule") do
        page.should have_content(@event.title)
      end
    end

    it "see my past games" do
      find("#nav-results a").click
      within(".main-content-results") do
        page.should have_content(@pastEvent.title)
      end
    end

  end

  context "logged-in user viewing another users profile" do

    before do
      user = FactoryGirl.create(:user)
      @new_user_data = FactoryGirl.attributes_for(:user)
      
      @profile_user = FactoryGirl.create(:user)

      as_user(user) do
        visit user_path(@profile_user.id)
      end
    end

    it "shows users profile" do
      within(".team-page-private") do
        page.should have_content(@profile_user.name.upcase)
      end
    end

  end

  context "logged-out user viewing another users profile" do

    before do      
      @profile_user = FactoryGirl.create(:user)

      visit user_path(@profile_user.id)
    end

    it "shows the users name" do
      within(".team-page-private") do
        page.should have_content(@profile_user.name)
      end
    end

    it "is the private profile page" do
      page.find(".team-page-private").should be_true
    end

  end

end

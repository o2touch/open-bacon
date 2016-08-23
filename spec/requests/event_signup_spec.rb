require 'spec_helper'


describe "as a team organiser logged in", :js => true do  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


  context "adding a new user to a future dated event"  do
    before do
      begin
        stop_sidekiq
        #Sidekiq::Testing.inline! do #we cant use this version of sidekiq yet!
          @user = FactoryGirl.create(:user, :with_team_events)
          team = @user.teams_as_organiser.first
          @event = team.upcoming_events.first
          @new_user_data = FactoryGirl.attributes_for(:user, :mobile_number => "+1234567890")
          
          AddPlayerToEventWorker.drain
          AddPlayersToEventWorker.drain
          
          as_user(@user) do
            visit event_path(@event.id)

            # open invite player popup
            find(".invite-player-button").click

            within(".invite-player-panel") do
              find("input.new-user-name").set(@new_user_data[:name])
              find("input.new-user-email").set(@new_user_data[:email])
              find("input#new-user-mobile-number").set(@new_user_data[:mobile_number])
              click_button("Send invite")
              # wait until processed
              AddPlayerToEventWorker.drain
              AddPlayersToEventWorker.drain
          
              find("button[title='send invite']").should have_no_css(".spinner")
            end
          end
        #end
      ensure
        start_sidekiq
      end
    end

    after(:all) do
      
    end

    it "displays the new user" do
      # reload page as pusher doesn't work in tests
      as_user(@user) do
        visit event_path(@event.id)
      end

      find(".users-list.awaiting").should have_content(@new_user_data[:name])
    end

    it "resets the add user fields" do
      within(".invite-player-panel") do
        find("input.new-user-name").value.should be_blank
        find("input.new-user-email").value.should be_blank
        find("input#new-user-mobile-number").value.should be_blank
      end
    end
  end
end



# keep this test as it has caught some bugs in the past
describe "as a team organiser with one event logged in", :js => true do  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction

  before(:each) do
    Event.any_instance.stub(:is_o2_touch_event?).and_return false
  end

  context "adding a new user to a future dated event"  do
    before do
      begin
        stop_sidekiq
       # Sidekiq::Testing.inline! do
          @user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 1)
          team = @user.teams_as_organiser.first
          @event = team.upcoming_events.first
          @new_user_data = FactoryGirl.attributes_for(:user, :mobile_number => "+1234567890")
          
          as_user(@user) do
            visit event_path(@event.id)

            find(".invite-player-button").click

            within(".invite-player-panel") do
              find("input.new-user-name").set(@new_user_data[:name])
              find("input.new-user-email").set(@new_user_data[:email])
              find("input#new-user-mobile-number").set(@new_user_data[:mobile_number])
              click_button("Send invite")
              # wait until processed
              find("button[title='send invite']").should have_no_css(".spinner")
            end
          end
        #end
      ensure
        start_sidekiq
      end
    end

    it "displays the new user" do
      # reload page as pusher doesn't work in tests
      as_user(@user) do
        visit event_path(@event.id)
      end

      find(".users-list.awaiting").should have_content(@new_user_data[:name])
    end

    it "resets the add user fields" do
      within(".invite-player-panel") do
        find("input.new-user-name").value.should be_blank
        find("input.new-user-email").value.should be_blank
        find("input#new-user-mobile-number").value.should be_blank
      end
    end
  end
end
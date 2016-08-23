require 'spec_helper'

include RequestHelpers

describe "View an event page", :type => :request, :js => true do

  self.use_transactional_fixtures = false # We need this because Capybara visit method breaks the transaction


  
  context "as an organiser" do

    before do
      begin
        stop_sidekiq
        @user = FactoryGirl.create(:user, :with_team_events)
        @event = @user.events.last
        @hour = "11"
        @min = "30"
        @ampm = "am"
        @month = "2"
        @day = "15"
        @year = Time.now.year + 1
        location = FactoryGirl.create(:location)
        @event.update_attributes(:game_type => 0, :time_zone => "Europe/Moscow", :time_local => "#{@year}-#{@month}-#{@day}T#{@hour}:#{@min}:00Z", :location => location)
        @event.save

        as_user(@user) do
          visit event_path(@event)
          #sleep 60
        end
      ensure
        start_sidekiq
      end
    end

    after(:all) do
      
    end

    it "shows event details", broken: true do
      within("#r-gamecard") do
        find("h1").should have_content(@event.title)
        find(".location").should have_content(@event.location.title)

        month_name = Date::MONTHNAMES[@month.to_i][0, 3]
        find(".day").should have_content(month_name)
        find(".day").should have_content("#{@hour}:#{@min}#{@ampm}")
      end

    end

#     it "can edit event" do
#       find("#r-gamecard .edit-details").click
#       new_location = "Las Vegas"
# 
#       new_title = "#{@event.title} 2"
#       within("#r-event-edit") do
#         # title
#         fill_in("eventTitle", :with => new_title)
#         # location
#         fill_in("eventLocation", :with => new_location)
#         # date (next month)
#         within(".gldp-flatwhite") do
#           find(".monyear .next-arrow").click
#           @new_month = @month.to_i + 1
#           # we use 21 because it wont appear in the year string until 2021
#           # and it wont appear in the few days from the prev month that sometimes
#           # show at the start of each month view
#           @new_day = "21"
#           first(".core", :text => @new_day).click

    it "can re-schedule an event", broken: true do
      within(".panel.action-panel") do
        find(".edit-event-schedule").click
      
        within(".panel.re-schedule") do
        
          # date (next month)
          within(".gldp-flatwhite") do
            find(".monyear .next-arrow").click
            @new_month = @month.to_i + 1
            @new_day = "21"
            first(".core", :text => @new_day).click
          end
          # time
          @new_hour = @hour.to_i - 1
          select(@new_hour, :from => "event-time-hour")
          select(@min, :from => "event-time-min")
          select(@ampm, :from => "event-time-ampm")
          find(".save-event").click

        end
      end
      
      within("#r-gamecard") do

        month_name = Date::MONTHNAMES[@new_month][0, 3]
        find(".day").should have_content(month_name)
        find(".day").should have_content(@new_day)
        find(".day").should have_content("#{@new_hour}:#{@min}#{@ampm}")
      end
    end
    
    it "can edit event", broken: true do
      new_title = "#{@event.title} 2"
      within(".panel.action-panel") do
        find(".edit-event-information").click
      end

      within(".panel.informations-edit.popover") do
        # title
        fill_in("eventTitle", :with => new_title)
        click_button("Save")
      end
    
      # view new details
      within("#r-gamecard") do
        find(".event-card").should have_content(new_title)
      end
    end
    
    it "can post an update"
    
    it "can invite players" do
      page.should have_css('.invite-player-button')
    end








    it "can post an update"

    it "can invite players" do
      page.should have_css('.invite-player-button')
    end

    # context "when adding players with valid details" do

    #   before do
    #     @newUser = FactoryGirl.build(:user)

    #     within(".teamsheet-invited") do
    #       find(".button").click
    #     end

    #     within(".invite-player-panel") do
    #       find("input.new-user-name").set(@newUser.name)
    #       find("input.new-user-email").set(@newUser.email)
    #       find("input.new-user-mobile-number").set(@newUser.mobile_number)
    #       find("button").click
    #       # wait until processed
    #       find("button .spinner.hide")
    #     end
    #   end

    #   # Removed this because this is tested in controller tests
    #   # it "adds player" do
    #   #   puts @newUser.email
    #   #   User.find_by_email(@newUser.email).should_not be_nil
    #   # end
    # end

    context "when adding players with invalid details" do

      before do
        @newUser = FactoryGirl.build(:user)

        find(".invite-player-button").click
      

        within(".invite-player-panel") do
          find("input.new-user-name").set(@newUser.name)
          find("input#new-user-mobile-number").set(@newUser.mobile_number)
          find("button").click
        end
      end

      # Wront scenario behavior       
      # it "validation fails" do
      #   find(".invite-player-panel").should have_css("input#user-mobile-number-container.error")
      # end

      it "does not add player" do
        User.find_by_email(@newUser.email).should be_nil
      end
    end

  end



  context "as a player" do

    it "allows user to post an update" do
      pending "add some examples to test"
    end

    it "allows user to respond with availability" do
      pending "add some examples to test"
    end
  end

end

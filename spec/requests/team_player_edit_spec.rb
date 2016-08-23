require 'spec_helper'

describe "as an event organiser logged in", :js => true do  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction

  context "return true" do
      it "returns true" do
        true.should == true
      end
  end

#   context "editing an existing unregistered team mate"  do
#     before :each do
#       user = FactoryGirl.create(:user, :with_team_events)
#       @unregistered_user = FactoryGirl.create(:user, :as_invited)
#       @unregistered_user.invited_by_source_user_id = user.id
#       @unregistered_user.save
#       @unregistered_user.reload

#       team = user.teams_as_organiser.first
#       event = team.upcoming_events.first
#       TeamUsersService.add_player(team, @unregistered_user)
      
#       as_user(user) do
#         visit team_path(team.id)
# player_li = nil
#         within(".teammates-list") do
#           players = page.all("li")
          
#           players.each do | player |
#             if player.find(".player-info").has_content?(@unregistered_user.name)
#               page.driver.browser.execute_script('$(".edit-player").trigger("click");') 
             
#               player_li = player
#             end
#           end
          
#           #within(player_li) do 
#             within(".teammates-edit") do #The below IDs clash on this page!
#               find(".player-name").set("+1234567890")
#               find(".player-email").set("+1234567890")            
#               find(".player-mobile-number").set("+1234567890")
#               p = page.find(".save")
#               p.click
#             end
#           #end
#         end

#                  page.driver.wait_until(page.driver.browser.switch_to.alert.accept)

#         begin
#          # pause
#         rescue Selenium::WebDriver::Error::UnhandledAlertError => e
#           #pause
#         end

#         @unregistered_user.reload
        
#       end
#     end

#     it "registers and displays the updated user" do
#        within(".teammates-list") do
#           players = page.all("li")
#           player_li = nil
             

#           players.each do | player |
#             if player.find(".player-info").has_content?(@unregistered_user.name)
#               page.driver.browser.execute_script('$(".edit-player").trigger("mouseover").trigger("click");') 
#               player_li = player
#             end
#           end
        
#           player_li.find(".teammates-edit") do #The below IDs clash on this page!
#           find(".player-name").value.should == @unregistered_user.name
#           find(".player-email").value.should == @unregistered_user.email
#           find(".player-mobile-number").value.should == "+1234567890"
#           end
#         end
#         @unregistered_user.mobile_number.should == "+1234567890"
#     end
#   end

  # context "editing an existing registered team mate" do
  #   before :each do
  #     user = FactoryGirl.create(:user, :with_team_events)
  #     @unregistered_user = FactoryGirl.create(:user)
  #     @unregistered_user.invited_by_source_user_id = user.id
  #     @unregistered_user.save
  #     @unregistered_user.reload

  #     team = user.teams_as_organiser.first
  #     event = team.upcoming_events.first
  #     TeamUsersService.add_player(team, @unregistered_user)
      
  #   as_user(user) do
  #       visit team_path(team.id)

  #       within(".teammates-list") do
  #         players = page.all("li")
  #         player_li = nil
  #         players.each do | player |
  #           if player.find(".player-info").has_content?(@unregistered_user.name)
  #             page.execute_script('$(".edit-player").trigger("mouseover").trigger("click");') 
  #             player_li = player
  #           end
  #         end
        
  #         player_li.find(".teammates-edit") do #The below IDs clash on this page!
  #           find_field("player-name").value.should == @unregistered_user.name
  #           find_field("player-email").value.should == @unregistered_user.email
  #           find_field("player-mobile-number").value.should == @unregistered_user.mobile_number
  #           fill_in "player-mobile-number", :with => "+1234567890"
  #           click_button(".save")
  #         end
  #       end

  #       #page.driver.wait_until(page.driver.browser.switch_to.alert.accept)
  #       @unregistered_user.reload
  #       pause
  #     end
  #   end

  #   it "registers and displays the user as is" do
  #     #page.driver.wait_until(page.driver.browser.switch_to.alert.accept)
  #     @unregistered_user.reload
  #     pause
  #     within(".teammates-list") do
  #       players = page.all("li")
  #       player_li = nil
  #       players.each do | player |
  #         if player.find(".player-info").has_content?(@unregistered_user.name)
  #           page.execute_script('$(".edit-player").trigger("mouseover").trigger("click")') 
  #           player_li = player
  #         end
  #       end
      
  #       player_li.find(".teammates-edit") do #The below IDs clash on this page!
  #         find_field("player-name").value.should == @unregistered_user.name
  #         find_field("player-email").value.should == @unregistered_user.email
  #         find_field("player-mobile-number").value.should == "+1234567890"
  #       end
  #     end
  #   end
  # end
end

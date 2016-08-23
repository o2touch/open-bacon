#
# Commented out this file as we no longer allow organisers to add/edit events from their profile pages
# 




# require 'spec_helper'

# describe "as a logged in organiser user", :js => true do  
  
#   self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction

#   context "viewing my dashboard" do

#     before do
#       @organiser = FactoryGirl.create(:user, :with_team_events, :team_count => 1)
#       @team = @organiser.teams_as_organiser.first
#       @pastEvent = FactoryGirl.create(:event, :game_type => 0, :team => @team, :user => @organiser, :time => 2.days.ago)
#       TeamEventsService.add @team, @pastEvent

#       as_user(@organiser) do
#         visit user_path(@organiser.id)
#       end
#     end

#     context "on the schedule tab" do

#       before do
#         find("#nav-schedule a").click
#         pause
#       end

#       it "add event" do
#         event = FactoryGirl.build(:event, :team => @team, :user => @organiser)
#         find("#schedule-event-form #add-game").click
#         pause
#         within("#add-event-form") do
#           find("input#event-title").set(event.title)
#           find("input#location").set(event.location)
#           find(".actions button").click
#         end
#         pause
#         # check it's there
#         within(".main-content") do
#           page.should have_content(event.title)
#         end
#       end

#       it "edit event" do
#         event = @organiser.events_created.first
#         within(".main-content .event-wrapper", :text => event.title) do
#           find(".availability button").click
#           pause
#           newLocation = "f9whhw98ffowf6ff9whd0fu"
#           find(".event-edit input.location").set(newLocation)
#           find(".event-edit .actions button").click
#           pause
#           page.should have_content(newLocation)
#         end
#       end

#     end

#     context "on the past games tab" do

#       before do
#         find("#nav-results a").click
#         pause
#       end

#       it "set score on past event" do
#         within(".main-content .event-wrapper", :text => @pastEvent.title) do
#           find("p.edit-score").click
#           pause
#           newScoreFor = "765432"
#           newScoreAgainst = "987654"
#           within(".score-form") do
#             find("input.score-for").set(newScoreFor)
#             find("input.score-against").set(newScoreAgainst)
#             find(".score-update").click
#           end
#           page.should have_content(newScoreFor)
#           page.should have_content(newScoreAgainst)
#         end
#       end

#     end

#   end

# end

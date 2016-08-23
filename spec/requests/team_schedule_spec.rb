require 'spec_helper'

describe "As an organiser", :js => true do

	self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


	context "view team schedule" do

		before :each do
			@organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
			@team = @organiser.teams_as_organiser.first
			@location = FactoryGirl.create(:location)
			@future_event = FactoryGirl.create(:event, :game_type => 0, :team => @team, :user => @organiser, :time_local => "#{Time.now.year+2}-01-01T12:00:00Z", :location => @location)
			@new_event_attr = FactoryGirl.attributes_for(:event, :title => "New title")

			@team.organisers.include?(@organiser).should be_true
			@organiser.team_roles(true)

			as_user(@organiser) do
				visit team_path(@team.id)
			end
			# click schedule tab
			find("#nav-schedule a").click
		end

		it "see my upcoming events" do
			find("#r-schedule-event-list").should have_content(@future_event.title)
		end



		context "adding an event" do

			before :each do
				find(".schedule-edit").click
				find(".schedule-add-event").click
			end

			it "shows the new event form and the preview" do
				find(".new-right-sidebar .event-edit-detail").should have_css("input#edit-event-title")
				find("#r-schedule-new-event-preview").should have_css(".event-row")
			end




			context "submitting new event form for single event" do

				before :each do
					# fill in form and submit

					within(".new-right-sidebar .event-edit-detail") do
						select(@location.title, :from => 'prev-locations')

						find("#edit-event-title").set(@new_event_attr[:title])
						# location
						select(@location.title, :from => 'prev-locations')
						# time
						@hour = "12"
						@minute = "30"
						@ampm = "pm"
						select(@hour, :from => "edit-event-hours")
						select(@minute, :from => "edit-event-minutes")
						select(@ampm, :from => "edit-event-ampm")

						click_button("Save")
					end
					# wait until processed
					find(".new-right-sidebar .edit-results-onboarding")

					@team.reload
				end

				it "displays the new event" do
					within first("#r-schedule-event-list .event-row") do
						find(".informations").should have_content(@new_event_attr[:title])
						find(".location").should have_content(@location.title)
						find(".time").should have_content("#{@hour}:#{@minute}#{@ampm}")
					end
				end

			end



			context "submitting new event form for repeating event", broken: true do

				before :each do
					@num_repeats = 3
					# fill in form and submit
					within(".new-right-sidebar .event-edit-detail") do
						find("#edit-event-title").set(@new_event_attr[:title])
						find("button[name='repeat']").click
						select('Monthly', :from => 'repeat-type')
						select(@num_repeats, :from => 'repeat-number')
						click_button("Save")
					end

					# show loading popup
					find(".repeat-events-popup")
				end

				it "displays the new event" do
					find("#r-schedule-event-list").should have_content(@new_event_attr[:title], :count => @num_repeats)
				end

			end

		end



		context "editing an event" do

			before :each do
				# this part sometimes fails and JO and TS can't figure out why
				# maybe just re-run the tests, or mark it as broken
				#puts @team.to_yaml
				#puts LandLord.new(@team).tenant.to_yaml

				find("#r-schedule-controls .view-mode .schedule-edit").click
				#sleep 60
				within("#r-schedule-event-list") do
					first(".event-row .informations").click
				end
			end

			it "shows the edit event form" do
				find(".new-right-sidebar .event-edit-detail").should have_css("input#edit-event-title")
			end




			context "submitting edit event form" do

				before :each do
					stop_sidekiq
					@new_location = "Las Vegas"
					# fill in form and submit
					within(".new-right-sidebar .event-edit-detail") do
						find("#edit-event-title").set(@new_event_attr[:title])
						find("#toggle-location-mode").click
						find("#edit-location").set(@new_location)
						click_button("Save")
					end
					start_sidekiq
					# wait until processed
					find(".new-right-sidebar .edit-results-onboarding")
				end

				it "updates the event" do
					within("#r-schedule-event-list .event-row") do
						page.should have_content(@new_event_attr[:title])
						page.should have_content(@new_location)
					end
				end




				context "exit edit mode" do

					before :each do
						find("#r-schedule-controls .edit-mode .schedule-view").click
					end

					after do
						# JO 19/07/13
						# Hack to workaround error: "Modal dialog present" which always appears on
						# Codeship in the first test of the file after this (currently team_squad_spec
						# but if I remove that file then it happens in the next one), BUT I cannot
						# reproduce this locally (in FF or Chrome), so putting this here for now. Sorry.
						# It tries to close an alert, and catches the exception if it can't find an
						# alert to close. Apparently there's no way to just check if one exists first.
						# http://stackoverflow.com/a/7864514/217866
						page.driver.browser.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
					end

					it "displays view mode" do
						find("#r-schedule-controls").should have_css(".schedule-edit")
						find(".new-right-sidebar").should have_css("#r-team-mates")
					end

				end

			end

		end

	end

end

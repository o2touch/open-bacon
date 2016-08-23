require 'spec_helper'

describe "as a guest on the signup page", :js => true do  
	
	self.use_transactional_fixtures = false # We need this because Capybara visit method breaks the transaction

	before :each do
		@team_attr = FactoryGirl.attributes_for(:team)
		visit '/signup'
	end

	################### STEP 1 - TEAM ####################

	context "on step 1 - team page" do

		context "with invalid name" do   
			before do        
				click_button 'Add team'
			end

			it "input goes red" do
				page.should have_css("input#team-name.error")
			end
		end

		context "with valid credentials" do

			before do
				fill_in 'team-name', :with => @team_attr[:name]
				find('#team-sport').select(@team_attr[:sport])
				find('#age-junior').set(true)
				find("#age-junior-kids").set(true)
				find(".colour-selector.primary li.colour-CC3543").click # red
				find(".colour-selector.secondary li.colour-2ABD7A").click # green
				click_button 'Add team'
			end

			it "shows step 2" do
				page.should have_css('#sf-organiser')
			end


			################### STEP 2 - ORGANISER ####################

			context "on step 2 - organiser page" do

				before do
					# prep details for step 2
					@organiser_attr = FactoryGirl.attributes_for(:user)
				end

				context "with invalid name" do
					before do
						fill_in 'signup_user_email', :with => @organiser_attr[:email]
						fill_in 'signup_user_mobile_number', :with => @organiser_attr[:mobile_number]
						fill_in 'signup_user_password', :with => 'password'
						click_button 'Next'
					end

					it "displays an error" do
						page.should have_content("Name can't be blank!")
					end
				end

				context "with no email" do
					before do  
						fill_in 'signup_user_name', :with => @organiser_attr[:name]
						# fill_in 'signup_user_mobile_number', :with => @organiser_attr[:mobile_number]
						fill_in 'signup_user_password', :with => 'password'
						click_button 'Next'
					end

					it "input goes red" do
						page.should have_css("input#signup_user_email.error")
					end
				end

				context "with blank password" do
					before do  
						fill_in 'signup_user_name', :with => @organiser_attr[:name]
						# fill_in 'signup_user_mobile_number', :with => @organiser_attr[:mobile_number]
						fill_in 'signup_user_email', :with => @organiser_attr[:email]
						click_button 'Next'
					end

					it "input goes red" do
						page.should have_css("input#signup_user_password.error")
					end
				end


				################### STEP 3 - CONFIRMATION AND REDIRECT ####################

				context "with valid details - confirmation and redirect" do  

					before do
						fill_in 'signup_user_name', :with => @organiser_attr[:name]
						fill_in 'signup_user_email', :with => @organiser_attr[:email]
						# fill_in 'signup_user_mobile_number', :with => @organiser_attr[:mobile_number]
						fill_in 'signup_user_password', :with => 'password'
						click_button 'Next'
					end

					it "redirects to new team page" do
						page.should have_selector('.team-page #team-profile', text: /#{@team_attr[:name]}/i)
					end

				end

			end

		end

	end

end 

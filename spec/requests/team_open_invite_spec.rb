require 'spec_helper'

describe "as a guest user", :js => true do  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction
  

  context "following a team open invite link" do
    before do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 0, :team_past_event_count => 0)
      @new_user_data = FactoryGirl.attributes_for(:user)
      @team = user.teams_as_organiser.first

      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      visit power_token_path(token)

      # login / signup popup will appear
      within(".signup-form") do
        fill_in "user-name", :with => @new_user_data[:name]
        fill_in "user-email", :with => @new_user_data[:email]
        fill_in "user-password", :with => @new_user_data[:password]
        click_button("Sign up")
      end
        
      within(".team-page-private") do
        find(".team-card").should have_content(@team.name.upcase)
        find(".signup-form form")
      end
      
       # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@new_user_data[:name])

      @new_user = User.find_by_email(@new_user_data[:email])
    end


    # these are covered by backend tests
    # it "creates the new user" do
    #   @new_user.should_not be_nil
    # end
    
    # it "adds the user to the team" do
    #   @team.has_member?(@new_user).should == true
    # end

    it 'redirects to the team_path' do
      current_url.should include team_path(@team)
    end

    it 'logs the user in' do
      find("#r-navigation").should have_content(@new_user.name)
    end

    it 'displays the confirmation popup' do
      find("#popup-content").should be_visible
      within("#popup-content") do
        find(".team-open-invite-confirmation").should have_content(@team.name)
      end
    end
  end

  context "following a team open invite link and confirming" do
    before do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 0, :team_past_event_count => 0)
      @new_user_data = FactoryGirl.attributes_for(:user)
      @team = user.teams_as_organiser.first

      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      visit power_token_path(token)

      # login / signup popup will appear
      within(".signup-form") do
        fill_in "user-name", :with => @new_user_data[:name]
        fill_in "user-email", :with => @new_user_data[:email]
        fill_in "user-password", :with => @new_user_data[:password]
        click_button("Sign up")
      end
      
      within(".team-page-private") do
        find(".team-card").should have_content(@team.name.upcase)
        find(".signup-form form")
      end

      # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@new_user_data[:name])

      within("#popup-content") do
        within(".team-open-invite-confirmation") do
          click_button("Explore")
        end
      end

      # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@new_user_data[:name])

      @new_user = User.find_by_email(@new_user_data[:email])
    end

    it 'redirects to the team_path' do
      current_url.should include team_path(@team)
    end

    it 'logs the user in' do
      find("#r-navigation").should have_content(@new_user.name)
    end

    it 'displays no popups' do
      page.should_not have_css("#popup-content")
    end
  end

  context "following a team open invite link via login" do
    before do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 0, :team_past_event_count => 0)
      @invitee = FactoryGirl.create(:user, :password => "password")
      @team = user.teams_as_organiser.first

      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      visit power_token_path(token)

      # login / signup popup will appear
      within(".signup-form") do
        click_link("Login")
      end

      fill_in "login-email", :with => @invitee.email
      fill_in "login-password", :with => "password"
      click_button("Log in")

      within(".team-page-private") do
        find(".team-card").should have_content(@team.name.upcase)
      end

      # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@invitee.name)

      within(".private-cta") do
        click_button("Join")
      end

      # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@invitee.name)

      @user_count = User.count
    end

    it 'does not create any new players' do
      @user_count.should == User.count
    end

    it 'redirects to the team_path' do
      current_url.should include team_path(@team)
    end

    it 'logs the user in' do
      find("#r-navigation").should have_content(@invitee.name)
    end
    
    it 'shows the team profile' do
      find(".team-page-private .team-card").should have_content(@team.name.upcase)
    end
    
    # Commented for private testing purpose     
    # it 'displays no popups' do
    #   page.should_not have_css("#popup-content")
    # end

    # it 'adds the user to the team' do
      # @team.has_member?(@invitee).should == true
    # end
  end

  context "following a team open invite link via login for a user already in the team" do
    before do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 0, :team_past_event_count => 0)
      @invitee = FactoryGirl.create(:user, :password => "password")

      @team = user.teams_as_organiser.first
      @team.add_player(@invitee)

      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      visit power_token_path(token)

      # login / signup popup will appear
      within(".signup-form") do
        click_link("Login")
      end
      
      within(".team-page-private") do
        find(".team-card").should have_content(@team.name.upcase)
        find(".login-form")
      end
      
      fill_in "login-email", :with => @invitee.email
      fill_in "login-password", :with => "password"
      click_button("Log in")

      # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@invitee.name)

      @user_count = User.count
      @team_role_count = PolyRole.count
    end
    
    # Commented for private team testing purpose     
    # it 'does not create any new players' do
      # @user_count.should == User.count
    # end

    it 'redirects to the team_path' do
      current_url.should include team_path(@team)
    end

    it 'logs the user in' do
      find("#r-navigation").should have_content(@invitee.name)
    end

    # Commented for private team testing purpose
    # it 'displays no popups' do
    #   page.should_not have_css("#popup-content")
    # end

    it 'does not add the user to the team' do
      @team_role_count.should == PolyRole.count
    end
  end

  context "following a team open invite link for a user already sign in not in the team" do
    before do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 0, :team_past_event_count => 0)
      @invitee = FactoryGirl.create(:user, :password => "password")

      @team = user.teams_as_organiser.first

      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      as_user(@invitee) do
        visit power_token_path(token)

        # login / signup popup will appear
        # wait until redirect finished (user will be logged in)
        find("#r-navigation").should have_content(@invitee.name)

        within(".team-page-private") do
          find(".team-card").should have_content(@team.name.upcase)
        end

        within(".private-cta") do
          click_button("Join")
        end
      end

      # wait until redirect finished (user will be logged in)
      find("#r-navigation").should have_content(@invitee.name)

      @user_count = User.count
    end

    it 'does not create any new players' do
      @user_count.should == User.count
    end

    it 'redirects to the team_path' do
      current_url.should include team_path(@team)
    end

    it 'logs the user in' do
      find("#r-navigation").should have_content(@invitee.name)
    end
    
    # Commented for private team testing purpose    
    # it 'displays no popups' do
    #   page.should_not have_css("#popup-content")
    # end

    # it 'adds the user to the team' do
      # @team.has_member?(@invitee).should == true
    # end
  end

  context "following a team open invite link for a user already sign in and in the team" do
    before do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 1, :team_event_count => 0, :team_past_event_count => 0)
      @invitee = FactoryGirl.create(:user, :password => "password")

      @team = user.teams_as_organiser.first
      @team.add_player(@invitee)

      @team.open_invite_link #Create the token
      route = team_path(@team) + "#open-invite"
      token = PowerToken.find_by_route(route)

      as_user(@invitee) do
        visit power_token_path(token)

        # login / signup popup will appear
        # wait until redirect finished (user will be logged in)
        find("#r-navigation").should have_content(@invitee.name)
      end

      @user_count = User.count
      @team_role_count = PolyRole.count
    end

    it 'does not create any new players' do
      @user_count.should == User.count
    end

    it 'redirects to the team_path' do
      current_url.should include team_path(@team)
    end

    it 'logs the user in' do
      find("#r-navigation").should have_content(@invitee.name)
    end

    it 'displays no popups' do
      page.should_not have_css(".team-open-invite-confirmation")
    end

    it 'does not add the user to the team' do
      @team_role_count.should == PolyRole.count
    end
  end
end
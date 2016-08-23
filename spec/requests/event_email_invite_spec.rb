require 'spec_helper' 

describe "as a guest user", :js => true do  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction
  

  # ADULTS
  context "as adult user (invited)" do

    before(:each) do
      organiser = FactoryGirl.create(:user, :with_team_events)
      team = organiser.teams_as_organiser.first
      @event = team.events.first

      @invited_user = FactoryGirl.create(:user, :as_invited, :invited_by_source => UserInvitationTypeEnum::EVENT)
      @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 
      @teamsheet_entry.update_attributes(:invite_sent => true)
      @teamsheet_entry.reload
    end

    context "when visiting the available link and setting a password" do
      before do        

        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'yes')

        # fill in signup popup
        within(".popup.signup") do
          fill_in "password", :with => "sandeep1234"
          find("button[type='submit']").click
        end
      end

      it 'registers the user fully' do
        @invited_user.is_registered? == true
      end

      it "displays the new user as signed in" do
        find("#main-navigation").should have_content(@invited_user.name)
      end

      it "displays the new user as available" do
        find(".users-list.available").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end

    context "visiting the unavailable link and setting a password" do
      before do
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'no')
      
        within(".popup.signup") do
          fill_in "password", :with => "sandeep1234"
          find("button[type='submit']").click
        end
      end

     it 'registers the user fully' do
        @invited_user.is_registered? == true
      end

      it "displays the new user as signed in" do
        find("#main-navigation").should have_content(@invited_user.name)
      end

      it "displays the new user as unavailable" do
        find(".users-list.unavailable").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end

    context "when visiting the event response link with 'k' response" do
      before do        
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'k')

        # fill in signup popup
        within(".popup.signup") do
          fill_in "password", :with => "sandeep1234"
          find("button[type='submit']").click
        end
      end

      it 'registers the user fully' do
        @invited_user.is_registered? == true
      end

      it "displays the new user as signed in" do
        find("#main-navigation").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end

    context "when visiting the event response link with incorrect response" do
      before do        
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'incorrect')
      end

      it 'registers the user fully' do
        @invited_user.is_registered? == false
      end

      it { find("#main-navigation").should have_content("Login") }

      it { current_url.should include event_path(@event) }

    end
  end

  context "as adult user (registered)" do

    before(:each) do
      organiser = FactoryGirl.create(:user, :with_team_events)
      team = organiser.teams_as_organiser.first
      @event = team.events.first

      @invited_user = FactoryGirl.create(:user, :invited_by_source => UserInvitationTypeEnum::EVENT)
      @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 

      @teamsheet_entry.update_attributes(:invite_sent => true) 
      @teamsheet_entry = @teamsheet_entry.reload
    end

    context "when visiting the available invite link" do
      before do
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'yes')
      end

      it { page.should_not have_content(".popup.signup") }

      it 'registers the user fully' do
        @invited_user.is_registered? == true
      end

      it "displays the new user as signed in" do
        find("#main-navigation").should have_content(@invited_user.name)
      end

      it "displays the new user as available" do
        find(".users-list.available").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end

    context "when visiting the unavailable invite link" do
      before do
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'no')
      end

      it { page.should_not have_content(".popup.signup") }

      it 'registers the user fully' do
        @invited_user.is_registered? == true
      end

      it "displays the new user as signed in" do
        find("#main-navigation").should have_content(@invited_user.name)
      end

      it "displays the new user as unavailable" do
        find(".users-list.unavailable").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end
  end

  # PARENTS
  context "as a parent (invited)" do  

    before do
      organiser = FactoryGirl.create(:user)
      team = FactoryGirl.create(:junior_team, :with_events, created_by: organiser)
      @event = team.events.first

      @parent = FactoryGirl.create(:user, :as_invited)

      @invited_user = FactoryGirl.create(:junior_user, parent: @parent)

      @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 
      @teamsheet_entry.update_attributes(:invite_sent => true)
      @teamsheet_entry = @teamsheet_entry.reload
    end

    context "clicking on the available link in the invite email and setting a password" do

      before do         
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'yes')

        # fill in signup popup
        within(".popup.signup") do
          fill_in "password", :with => "sandeep1234"
          find("button[type='submit']").click
        end
      end

      it 'registers the parent fully' do
        @parent.is_registered? == true
      end

      it "displays the parent as signed in" do
        find("#main-navigation").should have_content(@parent.name)
      end

      it "displays the child as available" do
        find(".users-list.available").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end

    context "clicking on the unavailable link in the invite email and setting a password" do

      before do
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'no')
        
        # fill in signup popup
        within(".popup.signup") do
          fill_in "password", :with => "sandeep1234"
          find("button[type='submit']").click
        end
      end

     it 'registers the parent fully' do
        @parent.is_registered? == true
      end

      it "displays the parent as signed in" do
        find("#main-navigation").should have_content(@parent.name)
      end

      it "displays the child as unavailable" do
        find(".users-list.unavailable").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end
  end

  context "as a parent (registered)" do  

    before do
      organiser = FactoryGirl.create(:user)
      team = FactoryGirl.create(:junior_team, :with_events, created_by: organiser)
      @event = team.events.first

      @parent = FactoryGirl.create(:user)

      @invited_user = FactoryGirl.create(:junior_user, parent: @parent)

      @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 
      @teamsheet_entry.update_attributes(:invite_sent => true)
      @teamsheet_entry = @teamsheet_entry.reload
    end

    context "clicking on the available link in the invite email" do

      before do         
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'yes')
      end

      it { page.should_not have_content(".popup.signup") }

      it 'registers the parent fully' do
        @parent.is_registered? == true
      end

      it "displays the parent as signed in" do
        find("#main-navigation").should have_content(@parent.name)
      end

      it "displays the child as available" do
        find(".users-list.available").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end

    context "clicking on the unavailable link in the invite email" do

      before do
        visit invite_link_path(:token => @teamsheet_entry.token, :response => 'no')
      end

      it { page.should_not have_content(".popup.signup") }

      it 'registers the parent fully' do
        @parent.is_registered? == true
      end

      it "displays the parent as signed in" do
        find("#main-navigation").should have_content(@parent.name)
      end

      it "displays the child as unavailable" do
        find(".users-list.unavailable").should have_content(@invited_user.name)
      end

      it 'redirect to the event page signed in' do
        current_url.should include event_path(@event)
      end
    end
  end

  context "no permissions to view the event" do

    before do
      organiser = FactoryGirl.create(:user)
      team = FactoryGirl.create(:junior_team, :with_events, created_by: organiser)
      @event = team.events.first

      @parent = FactoryGirl.create(:user)

      @invited_user = FactoryGirl.create(:junior_user, parent: @parent)

      @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 
      @teamsheet_entry.update_attributes(:invite_sent => true)
      @teamsheet_entry = @teamsheet_entry.reload
      
      visit invite_link_path(:token => @teamsheet_entry.token, :response => 'incorrect')
    end

    it { current_url.should include team_path(@event.team) }

  end

end

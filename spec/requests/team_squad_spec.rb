# Team page

require 'spec_helper'

describe "as an event organiser logged in", :js => true do  
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


  context "adding a new user to an adult team" do

    before do
      organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
      @new_user_data = FactoryGirl.attributes_for(:user)
      team = organiser.teams_as_organiser.first
      
      as_user(organiser) do
        visit team_path(team.id)

        # squad tab
        find("#nav-squad a").click

        within(".new-right-sidebar") do
          within("#r-squad-add-player-control-player") do
            find(".add-player").click
          end

          within(".squad-form") do
            fill_in("player-name", :with => @new_user_data[:name])
            fill_in("email", :with => @new_user_data[:email])
            fill_in("user-mobile-number", :with => @new_user_data[:mobile_number])
            click_button("Add")
          end

          # wait until processed
          find(".squad-form")
        end        
      end
    end

    it "displays the new user" do
      find("#r-squad-list").should have_content(@new_user_data[:name])
    end

  end




  context "adding a new user to a junior team" do

    before do
      organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
      @parent_user_data = FactoryGirl.attributes_for(:user)
      @junior_user_name = "Billy Boy"
      team = organiser.teams_as_organiser.first
      # junior team
      team.profile.update_attributes!(:age_group => AgeGroupEnum::UNDER_9)
      
      as_user(organiser) do
        visit team_path(team.id)

        find("#nav-squad a").click

        within(".new-right-sidebar") do
          within("#r-squad-add-player-control-player") do
            find(".add-player").click
          end

          within(".squad-form") do
            fill_in("player-name", :with => @junior_user_name)
            fill_in("parent-name", :with => @parent_user_data[:name])
            fill_in("parent-email", :with => @parent_user_data[:email])
            fill_in("user-mobile-number", :with => @parent_user_data[:mobile_number])
            click_button("Add")

            # wait until finished i.e. add button is no longer disabled
            #sleep 10
            find_button('Add')[:disabled].should_not be
          end
        end

        @parent_user = User.find_by_email(@parent_user_data[:email])
        @junior_user = @parent_user.children.first
      end
    end

    it "creates the new parent user" do
      @parent_user.should_not be_nil
    end

    it "creates the new junior user" do
      @junior_user.should_not be_nil
    end

    it "displays the new user" do
      find("#r-squad-list").should have_content(@junior_user_name)
    end

  end

end

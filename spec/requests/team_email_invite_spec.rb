require 'spec_helper'

describe "as an invited user", :js => true do
  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


  context "to a normal (non-league) team" do

    context "as LOU following a email invite link" do

      before :each do
        begin
          stop_sidekiq
          
            @user = FactoryGirl.create(:user, :as_invited)
            # 1 event so can try setting availability
            team = FactoryGirl.create(:team, :with_events, :event_count => 1)
            TeamUsersService.add_player(team, @user, false)

            team_invite = TeamInvite.get_invite(team, @user)
            #puts team_invite_link_path(:token => team_invite.token)
            visit team_invite_link_path(:token => team_invite.token)

            # wait for page to load and popup to display
            find("#popup-content .signup")
        ensure
          start_sidekiq
        end
      end


      it "can register", broken: true do
        within("#popup-content .signup") do
          fill_in "password", :with => "password"
          click_button("Confirm")
        end
        find(".grey-overlay").click #close download popup
        # popup closes
        page.should have_no_css("#popup-content")
      end



      # CANT CLOSE REGISTER POPUP ANY MORE
      # context "closing register popup" do

      #   before :each do
      #     find("#popup-content a.x").click #close register popup
      #     page.should have_no_css("#popup-content")
      #   end

      #   it "can still register after closing popup" do
      #     find("#r-godbar button[name='signup']").click
      #     within("#popup-content .signup") do
      #       fill_in "password", :with => "password"
      #       click_button("Confirm")
      #     end
      #     # as team does not have team_followable=true, we no longer show the download popup - instead we refresh

      #     # popup closes
      #     page.should have_no_css("#popup-content")
      #   end

      #   it "can close popup and change page and wont see popup again", broken: true do
      #     # click your user-link in nav bar
      #     find("#r-navigation .user-dropdown").click
      #     find("#r-navigation .user-link").click
      #     # wait for page to load
      #     find(".user-page .body")

      #     page.should have_no_css("#popup-content")
      #     # but should see godbar signup prompt instead
      #     page.should have_css("button[name='signup']")
      #   end

      #   it "can set availability" do
      #     begin
      #      # stop_sidekiq
      #         find("#nav-schedule a").click
      #         within("#r-schedule-event-list .event-row") do
      #           find("button.i-am-available").click
      #           page.should have_css("button.success")
      #         end
      #     ensure
      #      # start_sidekiq
      #     end
      #   end



      #   context "visiting user page" do

      #     before :each do
      #       # set availability so we have an activity item to try and like/comment on
            
      #         # find("#nav-schedule a").click
      #         # within("#r-schedule-event-list .event-row") do
      #           find("button.i-am-available").click
      #           page.should have_css("button.success")
      #         # end
      #         # 
      #         find("#r-navigation .user-dropdown").click
      #         find("#r-navigation .user-link").click

      #         # click your user-link in nav bar
      #         # visit user_path(@user.id)
      #         # wait for page to load
      #         find(".user-page .body")
      #     end

      #     it "cant add new team", broken: true do
      #       find("#r-team-panel button.show-form").click
      #       # opens register popup
      #       find("#popup-content a.x").click
      #       page.should have_no_css("#r-team-panel form")
      #     end


      #     it "can open edit-user form but can only edit team roles", broken: true do
      #       find(".panel.user-profile a.edit-user-profile").click
      #       page.should have_css("#r-team-roles")
      #       page.should have_no_css("#r-profile")
      #     end

      #     it "cant like activity", broken: true do
      #       #sleep 10
      #       like_button = find("#activity-feed .activity-item a.activity-item-like")
      #       like_button.click
      #       #sleep 60
      #       find("#popup-content a.x").click
      #       like_button.should have_no_content("Unlike")
      #     end

      #     it "cant comment on activity", broken: true do
      #       find(".activity-item a.toggle-comment-form").click
      #       find("#popup-content a.x").click
      #       page.should have_no_css(".activity-item .activity-comment-form")
      #     end

      #   end

      # end

    end


    context "as logged-in-user (not in team) following a email invite link" do

      before :each do
        user = FactoryGirl.create(:user)
        user.add_role(RoleEnum::INVITED)
        @team = FactoryGirl.create(:team)
        @team.add_player(user)

        team_invite = TeamInvite.get_invite(@team, user)
        as_user(user) do
          visit team_invite_link_path(:token => team_invite.token)
        end

        # wait for page to load
        find(".team-page")
      end

      it "gets normal team page" do
        within(".team-profile-details") do
          page.should have_selector('h1', text: /#{@team.name}/i)
        end
        # no popup
        page.should have_no_css("#popup-content")
      end

    end

  end




  context "to a league team" do
    # tests go here
  end

end
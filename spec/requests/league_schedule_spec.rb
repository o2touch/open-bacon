require 'spec_helper'

include LeagueHelper

describe "Viewing League profile", :js => true do

  self.use_transactional_fixtures = false #We need this because Capybara visit method breaks the transaction


  before :each do
    @league = FactoryGirl.create(:league)
    @organiser = @league.organisers.first
  end


  # publish/discard edits flow
  context "with unpublished fixture edits" do

    before :each do
      d = setup_division(@league, true)
      d.edit_mode = 1
      d.save

      f = d.fixtures.first
      @old_title = f.title
      @new_title = "New title"
      f.update_attributes!(title: @new_title)

      as_user(@organiser) do
        visit league_path(@league.id)
      end
    end

    it "shows only the published changes and button to edit schedule" do
      within(".body") do
        find(".fixture").should have_content(@old_title)
        find("#r-schedule-notice").should have_css("button[name='edit-schedule']")
      end
    end


    context "going into edit mode" do

      before :each do
        within("#r-schedule-notice") do
          find("button[name='edit-schedule']").click
          # wait for fixture edits to load
          page.should have_css("button[name='publish']")
        end
      end

      it "shows the unpublished edits and the publish button" do
        within(".body") do
          # fixture list view must have class .edit-mode for highlighting to work
          find(".edit-mode .fixture.edited").should have_content(@new_title)
          find("#r-schedule-notice").should have_css("button[name='publish']")
        end
      end

      it "still shows unpublished edits after changing tab and returning" do
        find("a[name='results']").click
        find("#r-schedule-fixture-list").should have_css(".page-empty")
        find("a[name='schedule']").click
        # fixture list view must have class .edit-mode for highlighting to work
        find(".body .edit-mode .fixture.edited").should have_content(@new_title)
      end


      context "publishing edits" do

        before :each do
          within("#r-schedule-notice") do
            find("button[name='publish']").click
            # wait for notice to change
            page.should have_no_css("button")
          end
        end

        it "shows notice for publishing in progress" do
          find("#r-schedule-notice").should have_css(".currently-publishing")
        end

        # JO 11/06/13 - Tim says we need sidekiq to publish changes
        # it "shows new fixtures as published" do
        #   within("#r-content") do
        #     find(".fixture").should have_content(@new_title)
        #     # check no notice box appears
        #     #find("#r-schedule-notice").should have_no_css(".alert-box")
        #   end
        # end

      end


      context "discarding edits" do

        before :each do
          within("#r-schedule-notice") do
            find("button[name='discard']").click
          end
        end

        it "shows old title in schedule" do
          find("#r-schedule-fixture-list .fixture").should have_content(@old_title)
        end

      end

    end

  end




  # add/edit/cancel/re-enable/delete fixture
  context "with an unpublished fixture" do

    before :each do
      d = setup_division(@league, false)

      # create the unpublished fixture
      FactoryGirl.create(:fixture, division_season: d, time_local: "#{Time.now.year+2}-01-01T12:00:00Z")

      as_user(@organiser) do
        visit league_path(@league.id)
      end

      find("#r-schedule-notice button[name='edit-schedule']").click
    end


    context "adding a fixture", broken: true do

      before :each do
        @title = "Semi-final"
        within(".sidebar-right") do
          find("button[name='add']").click
          find("input[name='name']").set(@title)
        end
        # check preview updated
        find("#r-schedule-preview .fixture").should have_content(@title)
        # submit
        stop_sidekiq
        find(".sidebar-right button[name='save-fixture']").click
        start_sidekiq
      end

      it "displays the new fixture in schedule" do
        find("#r-schedule-fixture-list").should have_content(@title)
      end

    end


    context "editing a fixture" do

      before :each do
        find("#r-schedule-fixture-list .fixture").click
        @new_title = "New title"

        within(".sidebar-right") do
          find("input[name='name']").set(@new_title)
          find("button[name='save-fixture']").click
        end
      end

      it "displays the new fixture in schedule" do
        find("#r-schedule-fixture-list .fixture").should have_content(@new_title)
      end

    end


    context "cancelling a fixture" do

      before :each do
        find("#r-schedule-fixture-list .fixture").click
        find(".sidebar-right button[name='cancel-fixture']").click
      end

      it "displays the fixture as cancelled in schedule" do
        find("#r-schedule-fixture-list").should have_css(".fixture.cancelled")
      end


      context "re-enabling a fixture" do

        before :each do
          find("#r-schedule-fixture-list .fixture.cancelled").click
          find(".sidebar-right button[name='re-enable']").click
        end

        it "no longer displays the fixture as cancelled in schedule" do
          # TODO: Fix this test
          # find("#r-schedule-fixture-list").should have_no_css(".fixture.cancelled")
        end

      end

    end


    context "deleting a fixture" do

      before :each do
        find("#r-schedule-fixture-list .fixture").click
        find(".sidebar-right a[name='delete-fixture']").click
        # accept JS confirm popup
        page.driver.browser.switch_to.alert.accept
      end

      it "can not see the deleted fixture" do
        find("#r-schedule-fixture-list").should have_no_css(".fixture")
      end

    end

  end


  # THIS SHIT NO LONGER APPLIES AS LEAGUE APP NO LONGER PUBLIC
  # context "as LOU" do

  #   before :each do
  #     d = setup_division(@league, true)
  #     d.edit_mode = 1
  #     d.save
  #     @title = d.fixtures.first.title

  #     visit league_path(@league.id)
  #   end

  #   it "can view schedule but has no edit button" do
  #     within(".body") do
  #       find("#r-schedule-fixture-list .fixture").should have_content(@title)
  #       page.should have_no_css("button[name='edit-schedule']")
  #     end
  #   end

  # end


end
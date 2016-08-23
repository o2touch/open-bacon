/**
 * NOTES
 *
 * division.edit_mode = enum for backend state
 * 0 = no unpublished changes
 * 1 = unpublished changes
 * 2 = currently publishing
 *
 * division.fetched = boolean for if we have fetched the published fixtures
 *
 * division.fetched_edits = boolean for if we have fetched the unpublished edits
 * if this is true it effectively means you are in edit mode
 * (set to false when go back to view mode)
 */
BFApp.Controllers.LeagueProfile = Marionette.Controller.extend({

  initialize: function() {
    // note: this page is now only for admins
    this.adminUser = true;//ActiveApp.CurrentUser.isLeagueOrganiser(ActiveApp.ProfileLeague);
    // league delegate
    this.ld = {
      adminUser: this.adminUser
    };
    this.isSetup = false;
    this.isFirstLoad = true;

    this.listenTo(BFApp.vent, "team:approve", this.approveTeam);
    this.listenTo(BFApp.vent, "team:reject", this.rejectTeam);
  },

  setupDivision: function(divisionId) {
    this.isDivisionChange = false;
    // if there is a division ID in URL
    if (divisionId) {
      // if it's first load, OR if the division has changed (from dropdown selection,
      // or pressing back button), update the dropdown and the tab links
      if (!this.ld.division || this.ld.division.get("id") != divisionId) {
        this.ld.division = ActiveApp.ProfileLeague.get("divisions").get(divisionId);
        var teamsCollection = new App.Collections.DivisionSeasonTeams([], {
          divisionSeasonId: divisionId
        });
        teamsCollection.fetch();
        this.ld.division.set("teams", teamsCollection);

        // if nonsense in URL
        if (!this.ld.division) {
          this.pushUrl("/");
          return false;
        }
        this.isDivisionChange = true;
      }
    } else if (this.isFirstLoad) {
      this.isFirstLoad = false;
      // no division ID in URL - try grabbing first from list
      var divisions = ActiveApp.ProfileLeague.get("divisions");
      if (divisions.length) {
        var url = "divisions/" + divisions.models[0].get("id");
        this.pushUrl(url);
        return false;
      }
    }

    return true;
  },

  setup: function(divisionId) {
    if (!this.setupDivision(divisionId)) {
      // redirecting
      return false;
    }

    if (this.isSetup) {
      // already setup, so just update links etc
      this.leagueDetail.updateDropdown();
      this.contentNaviView.updateLinks();
    } else {

      // Setup Main Layout
      this.mainLayout = new BFApp.Views.LeagueProfileLayout();
      BFApp.content.show(this.mainLayout);

      // League Details (header)
      this.leagueDetail = new BFApp.Views.ProfileLeagueDetail({
        model: ActiveApp.ProfileLeague,
        ld: this.ld
      });
      this.mainLayout.leagueProfile.show(this.leagueDetail);

      var className = convertSportCss(ActiveApp.ProfileLeague.get('sport')) + '-icon';
      this.mainLayout.leagueProfile.$el.addClass('sport-icon ' + className);

      this.listenTo(this.leagueDetail, "division:change", function(id) {
        var parts = Backbone.history.fragment.split("/");
        var url = "divisions/" + id;
        if (parts[2]) {
          url += "/" + parts[2];
        }
        this.pushUrl(url);
      });

      // if we have a division
      if (this.ld.division) {
        // Render Navigation (tabs)
        this.contentNaviView = new BFApp.Views.LeagueProfileNavi({
          showMessageTab: this.adminUser,
          showTeamsTab: this.adminUser,
          showMembersTab: this.adminUser,
          ld: this.ld
        });
        this.mainLayout.navi.show(this.contentNaviView);
        this.contentNaviView.updateLinks();


        // Sidebar widgets
        this.sidebarLayout = new BFApp.Views.LeagueSidebarLayout({
          ld: this.ld
        });
        this.mainLayout.widgets.show(this.sidebarLayout);
      } else {
        // if no division, then display message
        var emptyLeagueView = new BFApp.Views.EmptyMessage({
          title: "No Divisions Found",
          msg: "There is nothing to display here until the league admin adds a division to the league."
        });
        this.mainLayout.content.show(emptyLeagueView);

        return false;
      }

      this.isSetup = true;
    }

    return true;
  },

  pushUrl: function(url) {
    BFApp.LeagueProfile.router.navigate(url, {
      trigger: true
    });
  },

  showSchedule: function(divisionId) {
    this.context = "schedule";

    // the setup function may cause a redirect, in which case stop here
    if (!this.setup(divisionId)) {
      return false;
    }

    this.activeTab = new BFApp.Views.LeagueScheduleTab({
      showFutureFixtures: true,
      ld: this.ld
    });
    this.mainLayout.content.show(this.activeTab);

    this.displayScheduleContent();
    this.initScheduleListeners();
  },

  showResults: function(divisionId) {
    this.context = "results";

    // the setup function may cause a redirect, in which case stop here
    if (!this.setup(divisionId)) {
      return false;
    }

    this.activeTab = new BFApp.Views.LeagueScheduleTab({
      showFutureFixtures: false,
      ld: this.ld
    });
    this.mainLayout.content.show(this.activeTab);

    this.displayScheduleContent();
  },

  initScheduleListeners: function() {
    // clicked edit mode
    this.listenTo(this.activeTab, "edit:mode", this.enableEditMode);

    // clicked back/publish/discard changes
    this.listenTo(this.activeTab, "reload:schedule", function() {
      this.activeTab.preview.close();
      this.sidebarLayout.showTeamsWidget();
      this.fetchDivisionForSchedule();
    });

    // clicked add fixture
    this.listenTo(this.sidebarLayout, "add:fixture", function() {
      // note: we need to set title and location here, to make all of the model.hasChanged() stuff work
      var newLocation = new App.Modelss.Location({
        title: ""
      });
      var newFixture = new App.Modelss.Fixture({
        title: "",
        home_team_editable: true,
        away_team_editable: true,
        time_local: moment().add("days", 1).toCustomISO(),
        time_tbc: true,
        location: newLocation
      });

      this.activeTab.showPreviewFixture(newFixture);
      this.showFixtureEditForm(newFixture);
    });
  },

  initCommonListeners: function() {
    // clicked edit fixture
    this.listenTo(this.activeTab, "edit:fixture", function(fixture) {
      if (this.activeTab.showFutureFixtures) {
        this.activeTab.preview.close();
        this.showFixtureEditForm(fixture);
      } else {
        var resultsPanelLayout = this.sidebarLayout.showResultsPanelLayout(fixture);
        this.listenTo(resultsPanelLayout, "reload:standings", function() {
          this.activeTab.loadStandings();
        });
      }
    });
  },

  enableEditMode: function() {
    // first load locations
    if (!this.locations) {
      this.locations = new App.Collections.Locations();
      var that = this;
      this.locations.getLocations("league", ActiveApp.ProfileLeague.get("id"), {
        success: function() {
          that.locationsReady();
        }
      });
    } else {
      this.locationsReady();
    }
  },

  locationsReady: function() {
    this.sidebarLayout.showEditModeText();
    this.activeTab.updateSchedule();
    this.activeTab.showPublishEditsNotice();
  },

  showFixtureEditForm: function(fixture) {
    var formView = this.sidebarLayout.showEditForm(fixture, this.locations);

    this.listenTo(formView, "fixture:close", function() {
      this.activeTab.preview.close();
      this.sidebarLayout.showEditModeText();
      this.activeTab.highlightRow(null);
      this.activeTab.enableButton();
    });

    this.activeTab.disableButton();

    this.listenTo(formView, "schedule:change", function(collectionChanged) {
      if (collectionChanged) {
        this.activeTab.updateSchedule();
      } else {
        this.activeTab.rerenderSchedule();
      }
    });
  },

  // this will fetch the division data if we haven't already
  displayScheduleContent: function() {
    if (this.ld.division.get("fetched")) {
      // because this is only used on route change, we can use this.isDivisionChange
      this.divisionReady(this.isDivisionChange);
    } else {
      this.fetchDivisionForSchedule(this.isDivisionChange);
    }

    this.initCommonListeners();
  },

  fetchDivisionForSchedule: function(isDivisionChange) {
    // show loading
    this.activeTab.showLoading();
    if (isDivisionChange) {
      // because we know this is for the schedule tab, we know there will be a teamPanelView
      this.sidebarLayout.teamPanelView.showLoading();
    }

    var that = this;
    this.ld.division.fetchDivision({
      success: function() {
        // we store fetched and fetched_edits on the division object because once loaded,
        // we keep these objects in memory, so when you switch between already-loaded
        // divisions, we dont have to re-fetch anything
        that.ld.division.set("fetched", true);
        that.ld.division.set("fetched_edits", false);

        that.divisionReady();
      },
      error: function() {
        errorHandler();
      }
    });
  },

  divisionReady: function(isDivisionChange) {
    this.activeTab.updateSchedule();
    this.sidebarLayout.updateSidebar(this.context);
    this.activeTab.updateNotice();
  },

  /* Message tab */
  showMessages: function(divisionId) {

    /* Send user to schedule if not organizer */
    if (!this.adminUser) {
      this.pushUrl("divisions/" + divisionId + "/schedule");
      return false;
    }

    this.sidebarLayout.showEmpty();

    var that = this;

    /* Page setup */
    if (!this.setup(divisionId)) return false;
    // this.sidebarLayout.showTeamsWidget();

    /* If activity collection is not defined, create, fetch & connect to pusher */
    if (!this.activityItemCollection) {

      this.currentDivision = divisionId;

      /* Fetch and dispaly correct team, should be in the setup function */
      // this.sidebarLayout.initTeamPanel();
      // this.ld.division.fetch().always(function() {
      //   that.sidebarLayout.showTeamsWidget();
      // });

      /* Activity Collection */
      this.activityItemCollection = new App.Collections.ActivityItems();

      /* Activity Tab */
      this.activityFeedView = new BFApp.Views.ActivityFeedTab({
        activityItemCollection: that.activityItemCollection,
        canPostMsg: this.adminUser,
        isOrganiser: this.adminUser,
        context: "league",
        divisionId: divisionId
      });

      /* Spinner before fetching data */
      var spinner = new BFApp.Views.Spinner();
      that.mainLayout.content.show(spinner);

      /* Activity Collection Request */
      this.activityItemCollection.fetch({
        data: {
          feed_type: "profile",
          division_id: divisionId,
          item_count: -1
        }
      }).always(function() {
        that.mainLayout.content.show(that.activityFeedView);

      });

      /* Live update */
      if (BFApp.Pusher) {
        this.activityItemCollection.live({
          pusher: BFApp.Pusher,
          pusherChannel: BFApp.Pusher.subscribe("division-" + this.ld.division.get("id") + "-activity"),
          eventType: "activity_item"
        });
      }

      /* If you the division changed, reset */
    } else if (!this.currentDivision || this.currentDivision !== divisionId) {
      this.activityItemCollection = null;
      this.showMessages(divisionId);

      /* If tabView & ActivityCollection Exist, just show the existing views */
    } else {
      that.mainLayout.content.show(that.activityFeedView);
    }

  },

  /* Teams tab */
  showTeams: function(divisionId) {
    if (!this.setup(divisionId)) return false;

    this.sidebarLayout.showEmpty();

    var teamsView = new BFApp.Views.LeagueTeamsLayout({
      division: this.ld.division
    });

    this.mainLayout.content.show(teamsView);
  },

  approveTeam: function(team) {
    var divisionId = this.ld.division.get("id");

    team.approveForDivison(divisionId);
  },

  rejectTeam: function(team) {
    var divisionId = this.ld.division.get("id");

    team.rejectForDivison(divisionId);
  },

  /* Members Tab */
  showMembers: function(divisionId) {
    if (!this.setup(divisionId)) return false;

    this.sidebarLayout.showEmpty();

    /* Show League members view */
    var models = []; //this.ld.division.get("members").models;
    var membersCollection = new App.Collections.Users(models, {
      divisionSeasonId: divisionId
    });
    membersCollection.fetchDivisionSeason(divisionId, {});

    var membersView = new BFApp.Views.LeagueMembersLayout({
      division: this.ld.division,
      membersCollection: membersCollection
    });
    this.mainLayout.content.show(membersView);
  }

});
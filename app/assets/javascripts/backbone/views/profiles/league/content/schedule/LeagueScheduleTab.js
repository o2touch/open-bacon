/**
 * This is used for both the schedule and results tab
 */
BFApp.Views.LeagueScheduleTab = Marionette.Layout.extend({

  template: "backbone/templates/profiles/league/content/schedule/league_schedule_tab",
  className: "main-content main-content-schedule",

  regions: {
    standings: "#r-schedule-standings",
    notice: "#r-schedule-notice",
    controls: "#r-schedule-controls",
    preview: "#r-schedule-preview",
    fixtureList: "#r-schedule-fixture-list"
  },

  events: {
    "click .fixture": "clickedEditFixture",
    // "click .team-right, .team-left":"clickOnTeamLink"
  },
  
  scheduleState: "view",

  initialize: function(options) {
    this.showFutureFixtures = options.showFutureFixtures;
    this.ld = options.ld;

    if (!this.showFutureFixtures && this.ld.adminUser) {
      this.$el.addClass("results-tab");
    }
  },
  
  clickOnTeamLink:function(){
    if(this.scheduleState == "edit") return false;
  },

  clickedEditFixture: function(e) {
    if(this.ld.adminUser && (this.scheduleState == "edit" || !this.showFutureFixtures)){
      
      if(!this.showFutureFixtures && (!this.ld.division.get("track_results") || !this.ld.division.get("show_standings"))){
        return false;
      }
      
      var fixtureId = $(e.currentTarget).data("fixture-id");
      var fixtureModel = this.ld.division.get("fixtures").get(fixtureId);
      
      

      // highlight selected row
      this.highlightRow($(e.currentTarget));
      this.trigger("edit:fixture", fixtureModel);
      
      if (this.showFutureFixtures) {
        this.disableLink();
      }
      
  
      var tabName = (this.showFutureFixtures) ? "schedule" : "results";
      analytics.track('UX: Clicked '+tabName+' tab fixture edit', {
        user_id: ActiveApp.CurrentUser.get("id"),
        division_id: this.ld.division.get("id"),
        fixture_id: fixtureId
      });
    }
    return false;
  },
  
  disableButton:function(){
    this.$("button").prop("disabled", true);
  },
  
  enableButton:function(){
    this.$("button").prop("disabled", false);
  },
  
  disableLink:function(){
    this.$(".team-left, .team-right").addClass("disabled");
  },
  
  enableLink:function(){
    this.$(".team-left, .team-right").removeClass("disabled");
  },
  
  highlightRow: function(row) {
    this.$(".fixture").removeClass("selected");
    if (row) {
      row.addClass("selected");
    }
  },

  showLoading: function() {
    var spinner = new BFApp.Views.Spinner();
    this.fixtureList.show(spinner);
  },

  rerenderSchedule: function() {
    this.fixturesView.render();
  },

  updateSchedule: function() {
    // show content
    var fixtures = this.ld.division.get("fixtures");
    var fetchedEdits = this.ld.division.get("fetched_edits");
    var periodArray = fixtures.getFixtures(this.showFutureFixtures);
    var periodCollection = new App.Collections.Fixtures(periodArray, {
      ascendingOrder: this.showFutureFixtures
    });

    // Display events / empty message
    this.fixturesView = new BFApp.Views.ScheduleFixtureList({
      collection: periodCollection,
      itemView: BFApp.Views.ScheduleFixtureRow,
      emptyView: BFApp.Views.LeagueScheduleEmpty,
      showFutureFixtures: this.showFutureFixtures,
      ld: this.ld,
      viewingEdits: fetchedEdits
    });
    this.fixtureList.show(this.fixturesView);

    if (!this.showFutureFixtures) {
      this.showStandings();
    }

    /* Schedule navigation
    var that = this;
    var scheduleNavigationView = new BFApp.Views.LeagueScheduleNavigation({
      collection: periodCollection
    });
    this.controls.show(scheduleNavigationView);


    scheduleNavigationView.on("fixture:filter", function() {
      if (periodCollection.length > 0) {
        var searchText = scheduleNavigationView.ui.search.val().toLowerCase().trim();

        var searchResults = new App.Collections.Fixtures(_.filter(periodCollection.models, function(e) {
          return e.get("title").toLowerCase().indexOf(searchText) !== -1;
        }));

        fixturesView.setCollection(searchResults);
      }
    });
    */
  },

  showStandings: function() {
    if (this.ld.division.get("standings")) {
      this.standingsReady();
    } else {
      this.loadStandings();
    }
  },

  loadStandings: function() {
    // putting the check here instead of around the calls to this function as there are a few
    if (this.ld.division.get("show_standings")) {
      $("#r-schedule-standings").css("opacity", "0.5");
      var that = this;
      $.ajax({
        type: "get",
        url: '/api/v1/divisions/' + this.ld.division.get("id") + '/standings',
        dataType: 'json',
        success: function(data) {
          that.ld.division.set("standings", data);
          that.standingsReady();
        },
        error: function() {
          errorHandler();
        }
      });
    }
  },

  standingsReady: function() {
    $("#r-schedule-standings").css("opacity", "1");
    var standingsView = new BFApp.Views.StandingsTable({
      ld: this.ld
    });
    this.standings.show(standingsView);

    this.listenTo(standingsView, "reload:standings", this.loadStandings);
  },

  // after showing the main data, check if we need to show any notices
  updateNotice: function() {
    // edits are currently being published
    if (this.ld.division.get("edit_mode") == 2) {
      this.showPublishingNotice();
    }
    // else if admin user on schedule tab
    else if (this.ld.adminUser && this.showFutureFixtures) {
      // if already in edit mode
      if (this.ld.division.get("fetched_edits")) {
        this.showPublishEditsNotice();
      } else {
        this.showEditModeNotice();
      }
    }
  },

  showPreviewFixture: function(fixture) {
    var fixtureRowView = new BFApp.Views.ScheduleFixtureRow({
      model: fixture,
      className: "fixture selected",
      ld: this.ld
    });
    this.preview.show(fixtureRowView);
  },

  showEditModeNotice: function() {
    var noticeView = new BFApp.Views.EditModeNotice({
      ld: this.ld
    });
    this.notice.show(noticeView);

    this.listenTo(noticeView, "edits:ready", function() {
      this.trigger("edit:mode");
    });
    
    this.scheduleState = "view";
    this.enableLink();
    
  },

  showPublishEditsNotice: function() {
    var noticeView = new BFApp.Views.PublishEditsNotice({
      ld: this.ld
    });
    this.notice.show(noticeView);

    this.listenTo(noticeView, "reload:schedule", function() {
      this.notice.close();
      this.trigger("reload:schedule", false);
    });
    
    this.scheduleState = "edit";
    this.disableLink();
  },

  showPublishingNotice: function() {
    var noticeView = new BFApp.Views.PublishingNotice();
    this.notice.show(noticeView);
  }

});
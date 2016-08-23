BFApp.Views.SidebarResultsLayout = Marionette.Layout.extend({

  template: "backbone/templates/profiles/league/widget/sidebar_results_layout",

  className: "results-layout",

  regions: {
    results: "#r-sidebar-results",
    points: "#r-sidebar-points"
  },

  initialize: function(options) {
    this.fixture = options.fixture;
    this.ld = options.ld;
  },

  onRender: function() {
    var trackResults = this.ld.division.get("track_results");
    var showStandings = this.ld.division.get("show_standings");
    var scoringSystem = this.ld.division.get("scoring_system");
    scoringSystem = (scoringSystem) ? scoringSystem.toLowerCase() : "generic";

    /* Results panel view */
    if (trackResults) {
      var resultsPanel = new BFApp.Views.ResultsPanel({
        fixture: this.fixture,
        ld: this.ld,
        scoringSystem: scoringSystem
      });
      this.results.show(resultsPanel);

      if (showStandings) {
        this.listenTo(resultsPanel, "reload:standings", function() {
          this.trigger("reload:standings");
        });
      }
    }

    /* Points panel view */
    if (showStandings) {
      var pointsPanel = new BFApp.Views.FixturePointsPanel({
        fixture: this.fixture,
        pointsCategories: this.ld.division.get("points_categories"),
        ld: this.ld,
        scoringSystem: scoringSystem
      });
      this.points.show(pointsPanel);

      this.listenTo(pointsPanel, "reload:standings", function() {
        this.trigger("reload:standings");
      });
    }
  }
});
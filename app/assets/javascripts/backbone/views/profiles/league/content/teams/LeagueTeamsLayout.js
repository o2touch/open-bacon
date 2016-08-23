BFApp.Views.LeagueTeamsLayout = Marionette.Layout.extend({

  template: "backbone/templates/profiles/league/content/teams/league_teams_layout",

  regions: {
    active: "#r-active-teams",
    pending: "#r-pending-teams",
    registration: "#r-registration",
  },

  initialize: function(options) {
    this.division = options.division;
    this.teamsCollection = this.division.get("teams");

    this.listenTo(this.teamsCollection, "add remove reset change change:role_status", this.render);
  },

  onRender: function() {
    this.showMemberTeams();

    // TODO: Check permissions. Only viewable by league admin.
    this.showPendingTeams();
    this.showRegistration();
  },

  showMemberTeams: function() {
    var teams = this.teamsCollection.byMember();
    this.showTeamTable("active", teams, {
      title: "Teams",
      showAddNew: true
    });
  },

  showPendingTeams: function() {
    var teams = this.teamsCollection.byPending();

    if (teams.length > 0) {
      this.showTeamTable("pending", teams, {
        title: "Pending Teams",
        showAddNew: false
      });
    }

  },

  showRegistration: function() {
    var registrationPanelView = new BFApp.Views.LeagueRegistrationView({
      division: this.division
    });
    this["registration"].show(registrationPanelView);
  },

  showTeamTable: function(region, collection, options) {
    if (collection.length == 0) return this.showEmptyTeamTable(region, options.title);

    var teamsTableView = new BFApp.Views.TeamsTableView({
      collection: collection,
      title: options.title,
      showAddNew: options.showAddNew
    });
    this[region].show(teamsTableView);
  },

  showEmptyTeamTable: function(region, title) {
    var emptyTeamsTableView = new BFApp.Views.EmptyTeamsTableView({
      title: title
    });
    this[region].show(emptyTeamsTableView);
  }

});
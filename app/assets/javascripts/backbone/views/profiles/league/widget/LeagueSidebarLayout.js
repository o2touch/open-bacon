BFApp.Views.LeagueSidebarLayout = Marionette.Layout.extend({

  template: "backbone/templates/profiles/league/widget/league_sidebar_layout",

  className: "new-right-sidebar",

  regions: {
    main: "#r-sidebar-main"
  },

  initialize: function(options) {
    this.ld = options.ld;

    this.listenTo(BFApp.vent, "team:edit", this.showEditTeam);
    this.listenTo(BFApp.vent, "team:create", this.showCreateTeam);

    this.listenTo(BFApp.vent, "user:edit", this.showEditUser);
    this.listenTo(BFApp.vent, "user:create", this.showCreateMember);
  },

  showLoading: function() {
    var spinner = new BFApp.Views.Spinner();
    this.main.show(spinner);
  },

  updateSidebar: function(context) {
    var editMode = this.ld.division.get("fetched_edits");
    var canEdit = (this.ld.division.get("track_results") || this.ld.division.get("show_standings"));
    if (context == "schedule" && editMode) {
      // edit mode implies permissions, so go ahead and show edit mode text
      this.showEditModeText();
    } else if (context == "results" && this.ld.adminUser && canEdit) {
      this.showResultsOnboarding();
    } else {
      this.showTeamsWidget();
    }
  },

  showEmpty: function() {
    var sidebar = new BFApp.Views.LeagueTeamsSidebarLayout();
    this.main.show(sidebar);
  },

  showResultsPanelLayout: function(fixture) {
    var resultsPanelLayout = new BFApp.Views.SidebarResultsLayout({
      fixture: fixture,
      ld: this.ld
    });
    this.main.show(resultsPanelLayout);
    return resultsPanelLayout;
  },

  showResultsOnboarding: function() {
    var helpTextView = new BFApp.Views.LeagueResultsHelpText();
    this.main.show(helpTextView);
    sticky(helpTextView.$el, $(".sidebar-right"));
  },

  showEditModeText: function() {
    var helpTextView = new BFApp.Views.LeagueScheduleHelpText();

    var helpTextViewPanel = new BFApp.Views.PanelLayout({
      panelIcon: "pen",
      panelTitle: "Edit schedule",
      extendClass: "fixture-edit-text",
    });

    this.main.show(helpTextViewPanel);
    helpTextViewPanel.showContent(helpTextView);

    sticky(helpTextViewPanel.$el, $(".sidebar-right"));

    this.listenTo(helpTextView, "add:fixture", function() {
      this.trigger("add:fixture");
    });
  },

  showEditForm: function(fixture, locations) {
    var editFormPanel = new BFApp.Views.PanelLayout({
      panelIcon: "pen",
      extendClass: "fixture-edit",
      panelTitle: (fixture.isNew()) ? "New game" : "Edit game"
    });

    var formView = new BFApp.Views.ScheduleFixtureEdit({
      locations: locations,
      ld: this.ld,
      model: fixture
    });

    this.main.show(editFormPanel);
    editFormPanel.showContent(formView);

    sticky(editFormPanel.$el, $(".sidebar-right"));

    return formView;
  },

  onShow: function() {
    this.initTeamPanel();
  },

  initTeamPanel: function() {
    this.teamPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "badge",
      panelTitle: "Teams in division",
      extendClass: "teams"
    });
    this.main.show(this.teamPanelView);
    this.teamPanelView.showLoading();
  },

  showTeamsWidget: function() {
    this.initTeamPanel();

    var teamsPanelView = new BFApp.Views.TeamPanel({
      collection: this.ld.division.get("teams"),
      allowTeamCreation: false,
      title: "Teams in division"
    });

    this.teamPanelView.showContent(teamsPanelView);
  },

  showCreateTeam: function() {
    var team = new App.Modelss.DivisionSeasonTeam();
    this.showEditTeam(team, {
      type: "new"
    });
  },

  showEditTeam: function(team, options) {
    var attrs = {
      model: team,
      //className: "team-profile-edit-detail",
      type: (options && options.type) ? options.type : "edit",
      context: "league_admin",
      division_season: this.ld.division.get("id")
    };

    var teamFormView;
    if (ActiveApp.Tenant.get("name") == "o2_touch") {
      // this should be updated to something that extends TeamForm
      teamFormView = new BFApp.Views.O2TouchTeamForm(attrs);
    } else {
      teamFormView = new BFApp.Views.MitooTeamForm(attrs);
    }

    this.listenTo(teamFormView, "team:edit:cancel", this.showEmpty);
    this.listenTo(teamFormView, "team:saved", this.onTeamSave);

    var panelView = new BFApp.Views.PanelLayout({
      panelTitle: (options && options.type == "new") ? "Add Team" : "Edit Team",
      panelIcon: "pen",
      className: "panel edit-panel-style"
    });

    this.main.show(panelView);
    panelView.showContent(teamFormView);
  },

  onTeamSave: function(model) {
    this.ld.division.get("teams").add(model);
    this.showEmpty();
  },

  showCreateMember: function() {
    var user = new App.Modelss.User();
    this.showEditUser(user, {
      type: "new"
    });
  },

  showEditUser: function(user, options) {
    var formView = new BFApp.Views.SquadForm({
      model: user,
      //className: "user-profile-edit-detail",
      type: (options && options.type) ? options.type : "edit",
      context: "league_admin",
      secondParent: false,
      teams: this.ld.division.get("teams")
    });
    this.listenTo(formView, "cancel:clicked", this.showEmpty);

    var panelView = new BFApp.Views.PanelLayout({
      panelTitle: (options && options.type == "new") ? "Add Player" : "Edit Player",
      panelIcon: "pen",
      className: "panel edit-panel-style"
    });

    this.main.show(panelView);
    panelView.showContent(formView);
  }

});
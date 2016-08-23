BFApp.Views.TeamRowActionsView = Marionette.ItemView.extend({
  template: "backbone/templates/profiles/league/content/teams/team_row_actions_view",

  initialize: function(options) {
    this.team = options.team;
  },

  ui: {
    edit: ".edit",
    approve: ".approve",
    reject: ".reject",
  },

  events: {
    "click @ui.edit": "clickedEdit",
    "click @ui.approve": "clickedApprove",
    "click @ui.reject": "clickedReject"
  },

  serializeData: function() {
    return {
      isPartOfTheTeam: this.team.getDivisionSeasonRole() == 1 // Should be BFApp.constants.divisionSeasonTeamRole.MEMBER
    };
  },

  clickedEdit: function() {
    BFApp.vent.trigger("team:edit", this.team);
  },

  clickedApprove: function() {
    BFApp.vent.trigger("team:approve", this.team);
  },

  clickedReject: function() {
    BFApp.vent.trigger("team:reject", this.team);
  },

});
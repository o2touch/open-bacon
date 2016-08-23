// Class Name is different to filename because the Teams.js file needs to be included before this
App.Collections.DivisionSeasonTeams = App.Collections.Teams.extend({

  model: App.Modelss.DivisionSeasonTeam,

  initialize: function(models, options) {
    if (typeof options != "undefined") {
      this.divisionSeasonId = options.divisionSeasonId;
    }
    return this;
  },

  url: function() {
    return "/api/v1/teams?division_id=" + this.divisionSeasonId;
  },

  /* Return all member teams */
  byMember: function() {
    var that = this;
    var filtered = this.filter(function(team) {
      return team.getDivisionSeasonRole() == 1; //Should be BFApp.constants.divisionSeasonTeamRole.MEMBER but didnt work correctly;
    });
    return new App.Collections.DivisionSeasonTeams(filtered, {
      divisionSeasonId: that.divisionSeasonId
    });
  },

  /* Return all teams pending activation or rejected */
  byPending: function() {
    var that = this;
    var filtered = this.filter(function(team) {
      return team.getDivisionSeasonRole() == 2 || team.getDivisionSeasonRole() == 3;
    });
    return new App.Collections.DivisionSeasonTeams(filtered, {
      divisionSeasonId: that.divisionSeasonId
    });
  }

});
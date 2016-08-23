SearchApp.Views.TeamRow = Marionette.ItemView.extend({

  tagName: "li",

  className: "team-row",

  template: "backbone/templates/search/team_row",

  serializeData: function() {
    var highlightResult = this.model.get("_highlightResult");
    var teamName = (highlightResult.name) ? highlightResult.name.value : this.model.get("name");
    var leagueName = (highlightResult.league_name) ? highlightResult.league_name.value : this.model.get("league_name");
    var divisionName = (highlightResult.division_name) ? highlightResult.division_name.value : this.model.get("division_name");
    return {
      id: this.model.get("id"),
      htmlPic: this.model.getPictureHtml("thumb"),
      htmlTeamName: teamName,
      htmlLeagueName: leagueName,
      htmlDivisionName: divisionName
    };
  },

});
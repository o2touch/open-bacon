BFApp.Views.EmptyTeamsTableView = Marionette.CompositeView.extend({

  template: "backbone/templates/profiles/league/content/teams/empty_teams_table_view",

  className: "league-team-table empty-table",

  ui: {
    addNew: ".add-new-team"
  },

  events: {
    "click @ui.addNew": "clickedAddNewTeam",
  },

  serializeData: function() {
    return {
      title: this.options.title ? this.options.title : "Teams"
    }
  },

  clickedAddNewTeam: function() {
    BFApp.vent.trigger("team:create");
  }

});
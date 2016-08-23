BFApp.Views.TeamsTableView = Marionette.CompositeView.extend({

  itemView: BFApp.Views.TeamRowView,

  emptyView: BFApp.Views.TeamsTableEmptyView,

  itemViewContainer: "tbody",

  template: "backbone/templates/profiles/league/content/teams/teams_table_view",

  className: "league-team-table",

  ui: {
    addNew: ".add-new-team"
  },

  events: {
    "click @ui.addNew": "clickedAddNewTeam",
  },

  serializeData: function() {
    return {
      title: this.options.title,
      showAddNew: this.options.showAddNew
    }
  },

  clickedAddNewTeam: function() {
    BFApp.vent.trigger("team:create");
  }

});
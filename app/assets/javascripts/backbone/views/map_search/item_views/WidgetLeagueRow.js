BFApp.Views.WidgetLeagueRow = Marionette.ItemView.extend({

  template: "backbone/templates/map_search/widget_league_row",

  className: "widget-league-row",

  serializeData: function() {
    return {
      title: this.model.get("title"),
      id: this.model.get("id")
    };
  },

});
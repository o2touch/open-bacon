SearchApp.Views.LeagueRow = Marionette.ItemView.extend({

  tagName: "li",

  className: "team-row",

  template: "backbone/templates/search/league_row",

  serializeData: function() {
    var highlightResult = this.model.get("_highlightResult");
    var leagueName = (highlightResult.title) ? highlightResult.title.value : this.model.get("title");
    return {
      url: this.model.get("league_url"),
      htmlPic: this.model.getPictureHtml("thumb"),
      htmlLeagueName: leagueName
    };
  },

});
BFApp.Views.LeagueProfileLayout = Marionette.Layout.extend({

  className: "league-page",

  template: "backbone/templates/profiles/league/league_layout",

  regions: {
    leagueProfile: "#r-profile",
    navi: ".content-navi-container",
    widgets: "aside[role='complementary']",
    content: ".primary-content"
  }

});
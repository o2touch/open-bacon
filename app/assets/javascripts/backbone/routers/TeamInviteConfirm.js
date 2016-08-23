App.Routers.TeamProfile = Backbone.Router.extend({
  routes: {
    "": "confirmUserDetails",
    "*actions": "defaultRoute"
  },

  confirmUserDetails: function() {
    ActiveApp.TeamProfileShell = new App.Views.TeamProfileShell({
      model: ActiveApp.ProfileTeam,
      el: ".content"
    });
    TeamProfileApp.showView(ActiveApp.TeamProfileShell);
  },

  defaultRoute: function(path) {

  }
});
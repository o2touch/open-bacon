BFApp.module('LeagueProfile', {

  startWithParent: false,

  define: function(LeagueProfile, App, Backbone, Marionette, $, _) {

    LeagueProfile.addInitializer(function(options) {

      var leagueProfileController = new BFApp.Controllers.LeagueProfile(options);
      this.router = new BFApp.Routers.LeagueProfile({
        controller: leagueProfileController
      });

      // now the default identifier is the slug, but fallback to the id
      var id = ActiveApp.ProfileLeague.get("slug") || ActiveApp.ProfileLeague.get("id");

      // listen to clicks on league links, and use push state
      // from: http://dev.tenfarms.com/posts/proper-link-handling
      $(document).on("click", "a[href^='/leagues/"+id+"/']", function(event) {
        if (!event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey) {
          event.preventDefault();
          var url = $(event.currentTarget).attr("href").replace("/leagues/"+id+"/", "");
          BFApp.LeagueProfile.router.navigate(url, { trigger: true });
        }
      });

      Backbone.history.start({
        pushState: true,
        root: "/leagues/"+id+"/"
      });
    });

  }

});
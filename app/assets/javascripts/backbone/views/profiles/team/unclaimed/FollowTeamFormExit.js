BFApp.Views.FollowTeamFormExit = BFApp.Views.FollowTeamForm.extend({

  customSerializeData: function(data) {
    data.profileTeamId = this.team.get("id");
    data.teams = ActiveApp.DivisionTeams;
  },

  customFollowSuccess: function(teamName) {
    // close popup
    BFApp.vent.trigger("popup:close");
    
    // if this is an exit popup, we also need kiss metrics
    analytics.track('Followed FAFT Team', {context: "Leaving Popup"});
  }

});
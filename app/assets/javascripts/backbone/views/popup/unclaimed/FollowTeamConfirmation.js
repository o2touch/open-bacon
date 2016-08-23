BFApp.Views.FollowTeamConfirmation = Marionette.ItemView.extend({

  template: 'backbone/templates/popups/follow_team_confirmation',

  className:"team-open-invite-confirmation",

  serializeData: function() {
    return {
      teamName: this.options.teamName
    }
  }
});
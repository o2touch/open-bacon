BFApp.Views.TeamOpenInviteLinkConfirmationPopup = Marionette.ItemView.extend({

  template: 'backbone/templates/popups/open_invite_confirmation',
  className: 'team-open-invite-confirmation',

  events: {
    'click .confirmation': 'reloadTeamProfile'
  },

  initialize: function(options){
    this.teamName = options.teamName;
  },

  reloadTeamProfile: function() {
    disableButton(this.$(".confirmation"));
    window.location.hash = 'activity';
    window.location.reload(true);
  },

  serializeData:function(){
    return {
      teamName: this.teamName
    }
  }
});
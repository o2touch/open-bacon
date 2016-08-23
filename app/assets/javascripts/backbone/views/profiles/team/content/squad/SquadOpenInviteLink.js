BFApp.Views.SquadOpenInviteLink = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_open_invite_link",

  className: "squad-sidebar-section",

  events: {
    "click .show-open-invite-link": "showOpenInviteLink",
    "click input":"select"
  },

  select:function(e){
    $(e.currentTarget).select();
  },

  showOpenInviteLink: function() {
    this.$(".state-one").addClass("hide");
    this.$(".state-two").removeClass("hide");
    return false;
  },

  serializeData: function() {
    return {
      disable: ActiveApp.Teammates.hasDemoPlayers(),
      openInviteLink: ActiveApp.ProfileTeam.OpenInviteLink 
    }
  }

});

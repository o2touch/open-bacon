BFApp.Views.LeaguePendingView = Marionette.ItemView.extend({

  template: "backbone/templates/popups/join_league/league_pending_view",

  className: "join-league-flow join-league-pending-view",

  ui: {
    confirmButton: "button[name=confirm]"
  },

  events: {
    "click @ui.confirmButton": "clickedConfirm"
  },

  clickedConfirm: function() {
    disableButton(this.ui.confirmButton);
    // normally they will have registered, so we need to refresh
    // otherwise, they will have created a team anyway, so still may as well...
    window.location.href = "/teams/" + this.model.get("id");
  }

});
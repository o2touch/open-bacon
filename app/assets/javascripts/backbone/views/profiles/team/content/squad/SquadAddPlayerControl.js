BFApp.Views.SquadAddPlayerControl = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_add_player_control",

  className: "squad-onboarding",

  regions: {
    playerPanel: "#r-squad-add-player-control-player",
    linkPanel: "#r-squad-add-player-control-link",
    demoPlayerPanel: "#r-squad-add-player-control-demo-player"
  },

  triggers: {
    "click .add-player": "add-player:clicked"
  },

  onRender: function() {
    var playerView = new BFApp.Views.SquadAddPlayer();
    this.playerPanel.show(playerView);

    var pageOptions = ActiveApp.Tenant.get("page_options");

    if (pageOptions.show_team_page_invite_link && !ActiveApp.ProfileTeam.isJuniorTeam()) {
      var linkView = new BFApp.Views.SquadOpenInviteLink();
      this.linkPanel.show(linkView);
    }

    if (pageOptions.show_team_page_demo) {
      // only show the demo players section if the team doesn't have any real players (excluding yourself)
      var numPlayers = ActiveApp.Teammates.getNumPlayersExcludingMe(ActiveApp.ProfileTeam);
      if (numPlayers == 0 || ActiveApp.Teammates.hasDemoPlayers()) {
        var demoPlayerView = new BFApp.Views.SquadDemoPlayers();
        this.demoPlayerPanel.show(demoPlayerView);
        BFApp.vent.on("squad:toggle:demo", this.render);
      }
    }
  }

});
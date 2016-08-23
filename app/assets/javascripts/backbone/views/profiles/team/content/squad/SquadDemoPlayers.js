BFApp.Views.SquadDemoPlayers = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_add_demo_players",

  className: "squad-sidebar-section demo-players",

  events: {
    "click .add-demo-players": "addDemoPlayers",
    "click .remove-demo-players": "removeDemoPlayers"
  },

  onRender: function() {
    if (ActiveApp.Teammates.hasDemoPlayers()) {
      this.$(".state-one").addClass("hide");
    }
    else {
      this.$(".state-two").addClass("hide");
    }
  },

  addDemoPlayers: function() {
    var that = this;
    var buttonElem = this.$(".add-demo-players");
    this.toggleDemoMode(buttonElem, "post", function(data) {
      ActiveApp.Teammates.set(data, {parse: true});
      // hide add-demo-players button, show remove-demo-players button
      that.$(".state-one").addClass("hide");
      that.$(".state-two").removeClass("hide");
    });
  },

  removeDemoPlayers: function() {
    var that = this;
    var buttonElem = this.$(".remove-demo-players");
    this.toggleDemoMode(buttonElem, "delete", function(data) {
      ActiveApp.Teammates.reset(data, {parse: true});
      // hide remove-demo-players button, show add-players-button
      that.$(".state-one").removeClass("hide");
      that.$(".state-two").addClass("hide");
    });
  },

  toggleDemoMode: function(buttonElem, requestType, callback) {
    var that = this;
    disableButton(buttonElem);
    $.ajax({
      type: requestType,
      url: "/api/v1/teams/"+ActiveApp.ProfileTeam.get("id")+"/demo_users",
      dataType: 'json',
      data: {},
      success: function(data) {
        enableButton(buttonElem);
        if (typeof callback === "function") {
          callback(data);
        }
        BFApp.vent.trigger("squad:toggle:demo");
      },
      error: function() {
        errorHandler({
          button: buttonElem
        });
      }
    });
  }

});

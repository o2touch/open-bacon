SFApp.Views.SignupFlowTeam = Marionette.Layout.extend({

  template: "backbone/templates/signup_flow/team",

  events: {
    "click button[title='save']": "onSubmit",
    "click .colour-selector li": "changeColour",
  },

  regions: {
    newTeamForm: "#r-new-team",
    newOrganiser: "#r-new-organiser"
  },

  onShow: function() {
    var teamFormView = new BFApp.Views.MitooTeamForm({
      model: this.model,
      className: "eleven columns centered",
      type: "new"
    });

    this.newTeamForm.show(teamFormView);

    teamFormView.on("team:edit:cancel", function() {
      window.location = "";
    });

    teamFormView.on("team:saved", function(model) {
      window.location.hash = "#step2";
    });
  }

});
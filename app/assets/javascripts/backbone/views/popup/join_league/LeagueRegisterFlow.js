BFApp.Views.LeagueRegisterFlow = Marionette.Layout.extend({

  template: "backbone/templates/popups/join_league/league_register_flow",

  regions: {
    teamForm: "#lr-team-form",
    userForm: "#lr-user-form",
    pendingApproval: "#lr-pending-approval"
  },

  onRender: function() {
    // we want to add this markup when the layout is ready, but before it is actually displayed on the page
    this.team = new App.Modelss.Team();
    this.showTeamStage();

    // TESTING
    // this.showUserStage();
    // this.showPendingApprovalStage();
  },

  showTeamStage: function() {
    var that = this;

    var teamForm = new BFApp.Views.O2TouchTeamForm({
      title: "Create your Team",
      msg: "First of all, setup your team information",
      model: this.team,
      type: "new",
      noSave: true
    });
    this.teamForm.show(teamForm);

    this.listenToOnce(teamForm, "team:set", function(button) {
      if (ActiveApp.CurrentUser.isLoggedIn() && ActiveApp.CurrentUser.get("o2_fields_complete")) {
        this.createTeam(button);
      } else {
        // add in a second of loading here else it feels weird/fake
        setTimeout(function() {
          that.showUserStage();
        }, 1000);
      }
    });
  },

  showUserStage: function() {
    var userForm = new BFApp.Views.LeagueRegisterForm({
      model: ActiveApp.CurrentUser
    });
    this.userForm.show(userForm);

    this.listenToOnce(userForm, "next", this.createTeam);

    // insert nice transitions here
    this.userForm.$el.removeClass("hide");
    this.teamForm.$el.addClass("hide");
    // AND must always close views when done
    this.teamForm.close();
  },

  createTeam: function(button) {
    var that = this;

    this.team.saveToDivision(ActiveApp.ProfileDivision.get("id"), {
      success: function() {
        that.showPendingApprovalStage();
      },
      error: function() {
        errorHandler({
          button: button
        });
      }
    });
  },

  showPendingApprovalStage: function() {
    var pendingView = new BFApp.Views.LeaguePendingView({
      model: this.team
    });
    this.pendingApproval.show(pendingView);

    // insert nice transitions here
    this.pendingApproval.$el.removeClass("hide");
    // could be coming one of two stages
    if (this.teamForm.currentView) {
      this.teamForm.$el.addClass("hide");
      this.teamForm.close();
    } else if (this.userForm.currentView) {
      this.userForm.$el.addClass("hide");
      this.userForm.close();
    }
  }

});
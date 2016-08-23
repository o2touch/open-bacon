BFApp.Views.SignupPopup = Marionette.Layout.extend({

  tagName: "div",

  className: "signup-popup",

  template: "backbone/templates/popups/signup_popup",

  allowClosePopup: true,

  regions: {
    signupForm: "#r-signup-form"
  },

  serializeData: function() {
    var title,
      msg,
      tenant = ActiveApp.Tenant.get("general_copy").app_name;

    if (ActiveApp.CurrentUser.needsPassword()) {
      title = "Set a password";
      msg = false;
    } else {
      title = "Confirm to ";
      msg = "Hi there, just confirm with Facebook or set a password to get full access to ";
      // if no teams
      if (ActiveApp.CurrentUserTeams && !ActiveApp.CurrentUserTeams.length) {
        title += "join " + tenant;
        msg += tenant + ".";
      } else {
        var teamName = "your team";
        var isFaftTeamProfile = (ActiveApp.ProfileTeam && ActiveApp.ProfileTeam.get("is_faft_team"));

        // don't use the team name if you're on a faft team page
        // as we don't know if the profileTeam is the one they're invited to,
        // and SR says we can't know this on this page, so just keep the copy generic
        // UPDATE: this also applies to all team pages, so currently can't ever use team name
        // if (ActiveApp.ProfileTeam && !isFaftTeamProfile) {
        //   teamName = ActiveApp.ProfileTeam.get("name");
        // }

        // hack to use the word "follow" on faft team pages
        var verb = (isFaftTeamProfile) ? "follow" : "join";

        // also use "follow" if the currentUser has been invited to follow the profileTeam
        if (ActiveApp.CurrentUser.isInLimbo()) {
          // if on team profile, and you are invited to follow that team
          if (ActiveApp.ProfileTeam && ActiveApp.CurrentUser.isFollower(ActiveApp.ProfileTeam)) {
            verb = "follow";
          }
        }

        title += verb + " " + teamName + " on " + tenant;
        msg += teamName + "'s content on " + tenant + ".";
      }
    }

    return {
      title: title,
      message: msg
    }
  },

  onRender: function() {
    var that = this;
    var signupFormView = new BFApp.Views.SignupForm({
      model: ActiveApp.CurrentUser,
      signupOptions: this.options,
      title: false,
      showLogin: false
    });
    signupFormView.on("login:clicked", function() {
      that.trigger("show:login");
    });

    this.signupForm.show(signupFormView);
  }
});
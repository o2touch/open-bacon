BFApp.Views.FollowTeamFormPaywall = BFApp.Views.FollowTeamForm.extend({

  template: "backbone/templates/profiles/team/unclaimed/follow_team_form_paywall",

  events: {
    "click .dowload-app-redirect": "endExperiment",
    "change @ui.teamInput": "teamSelection"
  },

  onShow: function(options) {
    this.$(".show-form").click(function(e) {
      e.preventDefault();
      $(this).addClass("hide");
      $(".form-manual").removeClass("hide");
    });

    this.$(".form-manual").submit(function(e) {
      e.preventDefault();
    });

    this.$el.addClass("no-facebook-signup");
  },

  customOnRender: function() {
    this.selectedTeamButton = this.$("button[name='team-name']");
  },

  teamSelection: function() {
    var selectedTeam = this.ui.teamInput.children(":selected").text();
    this.selectedTeamButton.text(selectedTeam);
  },

  /* 
    Follow VS Download test:
    https://trello.com/c/DXDAkJGW/158-piers-public-team-page-download-app-test-2

    Experiment start in the BFApp.Views.FollowTeamPopupPaywall view
  */
  endExperiment: function() {
    if (this.options.followVersusDownloadTest) {
      Split.finishExperiment(this.options.followVersusDownloadTest.experiment);
    }
  },

  serializeData: function() {
    return {
      followVersusDownloadTest: this.options.followVersusDownloadTest,
      teams: (ActiveApp.profileType == "division") ? ActiveApp.ProfileDivision.get(
        "teams") : null
    };
  },

  validateForm: function() {
    var isValidEmail = BFApp.validation.isEmail({
      htmlObject: this.ui.emailInput
    });

    return isValidEmail;
  },


  followAnalytics: function(type, status) {
    metricsOptions = {
      type: type,
      "initial_status": status,
      context: "FAFT Team Paywall Popup"
    };
    BFMetricsService.clickedFollowTeam(metricsOptions);
  },

  facebookAuthAnalytics: function(token) {
    var name = Boolean(token) ? "Facebook Auth Success" : "Facebook Auth Failure";
    options = {
      successful: name,
      context: "FAFT Team Paywall Popup"
    };
    BFMetricsService.authenticatedWithFacebook(options);
  },

  getUserData: function() {
    var email = this.ui.emailInput.val().trim();
    var data = {
      name: email,
      email: email
    };
    return data;
  },

  customFollowSuccess: function(teamName, button, type, model, downloadPopupOptions) {
    this.endExperiment();
    if (type == "Email") {
      // show password popup
      BFApp.vent.trigger("paywall-flow:next", {
        teamName: teamName,
        paywallPassword: true,
        password: model.get("generated_password"),
        downloadPopupOptions: downloadPopupOptions
      });
    }
    // only close popup if not showing the download popup
    else if (type == "Facebook" && downloadPopupOptions) {
      BFApp.vent.trigger("download-app:show", downloadPopupOptions);
    }

    BFMetricsService.followedTeam({
      type: type,
      context: "FAFT Team Paywall Popup",
      abTest: "paywall_facebook_signup"
    });
  }

});
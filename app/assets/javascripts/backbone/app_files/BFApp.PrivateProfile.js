BFApp.module('PrivateProfile', {

  startWithParent: false,

  define: function(PrivateProfile, App, Backbone, Marionette, $, _) {

    PrivateProfile.addInitializer(function(options) {

      /* Analytics */
      analytics.track('Viewed Private ' + options.context + 'Page', {
        'context': options.context,
        'isLoggedIn': ActiveApp.CurrentUser.isLoggedIn()
      });

      $("body").addClass("private");


      /* General private controller */
      var PrivateProfileController = new BFApp.Controllers.PrivateProfile(options);

      /* This is the copy for the godbar message - for logged in user */
      var headerMessage = {
        type: "team-onboarding-godbar bluefields-blue stripe team-color",
        icon: "lock",
        message: "This Team profile is private",
        explanation: "You need to be a member to view this page"
      };



      if (options.context == "team") {
        /* For styling purpose */
        var sportClass = convertSportCss(ActiveApp.ProfileTeam.get("sport"));
        $("body").addClass('sport-background ' + sportClass + '-background');

      } else if (options.context == "user") {
        $("body").addClass("user");
        headerMessage.message = "This user\'s profile is private";
        headerMessage.explanation = "You need to be friends with this user to see more information.";
      }

      /* Open Invite link check */
      var OpenInviteLink = (getParameterByName("token") !== "");

      /* Open Invite Link */
      if (OpenInviteLink) {
        PrivateProfileController.showLayout("2");
        if (ActiveApp.CurrentUser.isLoggedIn()) {
          PrivateProfileController.showInvite();
        } else {
          PrivateProfileController.showTeamSignup("team-oil");
        }
      }

      /* Logged in */
      else if (ActiveApp.CurrentUser.isLoggedIn()) {
        PrivateProfileController.showLayout("1");

        /* Showgodbar */
        PrivateProfileController.showHeader(headerMessage);
      }

      /* Logged Out */
      else {
        PrivateProfileController.showLayout("2");
        PrivateProfileController.showCTASignup(options.context);
      }

      /* Show the team/user card */
      if (options.context == "team") {
        PrivateProfileController.showTeamCard();
      } else if (options.context == "user") {
        PrivateProfileController.showUserCard();
      }




      Backbone.history.start();

    });
  }

});
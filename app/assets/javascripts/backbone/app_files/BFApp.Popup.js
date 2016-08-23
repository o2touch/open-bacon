BFApp.module('Popup', {

  startWithParent: false,

  define: function(Popup, App, Backbone, Marionette, $, _) {

    Popup.addInitializer(function() {

      var controller = new BFApp.Controllers.Popup();

      /* update the popup to prevent it being closed */
      BFApp.vent.on("popup:disable:close", function(options) {
        controller.disableClose();
      });

      /* Signup call */
      BFApp.vent.on("signup-popup:show", function(options) {
        controller.signUp(options);
      });

      /* Login call */
      BFApp.vent.on("login-popup:show", function() {
        controller.login(true);
      });

      /* Help call */
      BFApp.vent.on("popup:show", function(options) {
        controller.showPopup(options);
      });

      /* Generic text popup */
      BFApp.vent.on("generic-text:show", function(options) {
        controller.genericText(options);
      });

      /* Team Open Invite link call */
      BFApp.vent.on("team-open-invite-link-confirmation-popup:show", function(teamName) {
        controller.teamOpenInviteLinkConfirmation(teamName);
      });

      /* Repeating Events Popup */
      BFApp.vent.on("repeat-events-popup:show", function(numRepeats) {
        controller.repeatEvents(numRepeats);
      });

      /* Download app  */
      BFApp.vent.on("download-app:show", function(options) {
        controller.downloadPopup(options);
      });

      /* Follow team  */
      BFApp.vent.on("follow-team:show", function(options) {
        controller.followTeam(options);
      });

      /* Follow team confirmation */
      BFApp.vent.on("follow-team-confirmation:show", function(teamName) {
        controller.followTeamConfirmation(teamName);
      });

      /* Generic text popup */
      BFApp.vent.on("generic-text:show", function(options) {
        controller.genericText(options);
      });

      /* Event register popup */
      BFApp.vent.on("event-register-form:show", function(options) {
        controller.eventRegisterForm(options);
      });

      /* Event register popup */
      BFApp.vent.on("league-register-form:show", function(options) {
        controller.leagueRegisterForm(options);
      });

      /* Team form popup */
      BFApp.vent.on("team-form:show", function(options) {
        controller.teamForm(options);
      });

      /* League form popup */
      BFApp.vent.on("league-form:show", function(options) {
        controller.leagueForm(options);
      });

      BFApp.vent.on("create-division-form:show", function(options) {
        controller.createDivisionForm(options);
      });

      // League claim form popup
      BFApp.vent.on("claim-league-form:show", function(options) {
        controller.claimLeagueForm(options);
      });

      /* Close popup */
      BFApp.vent.on("popup:close", function(popupGoalCompleted) {
        controller.closePopup(popupGoalCompleted);
      });

    });

  }

});
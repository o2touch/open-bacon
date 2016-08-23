BFApp.module("FaftProfile", {

  startWithParent: false,

  define: function(profile) {
    BFApp.addRegions({
      faftSidebar: "#right-sidebar"
    });

    profile.addInitializer(function(options) {

      var controller = new BFApp.Controllers.FaftProfile(options);
      controller.setup();

      /* Show correct state  */

      // Show paywall if:
      // tenant settings say to,
      // is team page or division page,
      // not clicked close paywall button,
      // not already following team,
      // not logged in, 
      // not specified URL arg paywall=false
      if (ActiveApp.Tenant.get("page_options").team_followable && (ActiveApp.profileType == "team" || ActiveApp.profileType == "division") && !$.cookie('clickedExitPopup') && !ActiveApp.CurrentUser.isFollowingFaftTeam && !ActiveApp.CurrentUser.isLoggedIn() && getParameterByName("paywall") !== "false") {

        /***/
        /* PTP Test 1: Mobile Download - See https://trello.com/c/12xk1RMY */
        /*****/
        // if(options.mobileDevice){      
        //   var experiment = BFMetricsService.participateInTest("ptp_download_test_1");
        //   if(experiment.alternative!="control"){
        //     controller.showMobileDownloadAppPopup();
        //     controller.changeState("paywall");
        //     return;
        //   }
        // }
        /*****/
        /* End PTP Test 1 */
        /*****/

        // Default Behaviour & Test Control
        controller.showPaywall();

        controller.changeState("paywall");
      } else if (ActiveApp.CurrentUser.isFollowingFaftTeam || ActiveApp.profileType == "league") {
        controller.changeState("download");
      } else {
        controller.changeState("follow");
      }

    });
  }

});
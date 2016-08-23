BFApp.Views.FollowTeamPopupPaywall = BFApp.Views.FollowTeamPopup.extend({

  template: "backbone/templates/popups/follow_team_paywall",

  className: "paywall-popup-flow-signup",

  events: {
    "click .exit-popup": "clickedClose",
    "click .search": "clickedSearch",
    "click .login": "showLogin"
  },

  initialize: function() {

    /* 
      Follow VS Download test:
      https://trello.com/c/DXDAkJGW/158-piers-public-team-page-download-app-test-2
    */
    this.followVersusDownloadTest = false;
    if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
      this.followVersusDownloadTest = Split.getAlternative("paywall_follow_vs_download");
    }

  },

  serializeData: function() {

    /* 
      Change of copy depending on Follow VS Download test
    */
    var copy = {
      whyTitle: "Why do I need to follow?",
      whyDescription: "Always have the latest details. We track league fixtures and results and send you accurate updates whether you are a player, parent or team admin.",
      topTitle: "You must Follow to see upcoming games<br>and the league table",
      topDescription: "We won't store your password or spam you or your friends."
    };

    if (this.followVersusDownloadTest && this.followVersusDownloadTest.alternative == "download") {
      copy = {
        whyTitle: "Why do I need to Download the app?",
        whyDescription: "Always have the latest details. We track league fixtures and results and send you important updates, whether you are a player, parent or team admin.",
        topTitle: "You must download the free mitoo app to see the upcoming games and the leagues tables",
        topDescription: "We won't store your password or spam you or your friends."
      };
    }

    return {
      copy: copy
    };
  },

  onShow: function() {
    this.options.followVersusDownloadTest = this.followVersusDownloadTest;
    var teamForm = new BFApp.Views.FollowTeamFormPaywall(this.options);
    this.formRegion.show(teamForm);

    analytics.track("Viewed FAFT Team Paywall Popup", {});
  },

  clickedClose: function(e) {
    e.preventDefault();
    analytics.track("Clicked Close Popup Link", {
      context: "FAFT Team Paywall Popup"
    });
    $("body").removeClass("paywall");
    BFApp.vent.trigger("popup:close");
    BFApp.vent.trigger("change:state", {
      state: "follow"
    });
    $.cookie('clickedExitPopup', true);
  },

  clickedSearch: function() {
    analytics.track("Clicked Search Link", {
      context: "FAFT Team Paywall Popup"
    });
  },

  showLogin: function(e) {
    e.preventDefault();
    BFApp.vent.trigger("login-popup:show");
    analytics.track("Clicked Login Link", {
      context: "FAFT Team Paywall Popup"
    });
  }

});
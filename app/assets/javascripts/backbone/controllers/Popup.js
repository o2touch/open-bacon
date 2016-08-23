BFApp.Controllers.Popup = Marionette.Controller.extend({

  disableClose: function() {
    this.popupLayout.options.allowClosePopup = false;
    this.popupLayout.ui.closeButton.remove();
  },

  /* Layout actions */
  showLayout: function(view, popupClass, allowCloseButton, options) {
    this.popupLayout = new BFApp.Views.PopupLayout({
      allowClosePopup: allowCloseButton,
      animation: (!this.currentPopupView),
      popupClass: popupClass
    });

    default_options = {
      centered: true,
      fullScreen: false
    };
    jQuery.extend(default_options, options);

    BFApp.popupRegion.show(this.popupLayout);

    this.popupLayout.popupContent.show(view);

    this.listenTo(this.popupLayout, "close:popup", function() {
      this.closePopup();
    });

    if (default_options.centered) {
      var popup = this.popupLayout.$(".popup, .new-popup");
      popup.css({
        "margin-left": -popup.outerWidth() / 2,
        "margin-top": -popup.outerHeight() / 2,
      });
    }

    if (default_options.fullScreen) {
      $("#r-module").hide();
      var popupLayout = $(".popup-layout");
      popupLayout.css({
        "position": "absolute"
      });
    }

    $("body").addClass("noscroll");
  },

  closePopup: function(popupGoalCompleted) {
    $("body").removeClass("noscroll");
    if (ActiveApp.pageType == "team-open-invite") {
      return false;
    }

    $("#r-module").show();

    if (this.currentPopupView == "signup" && !popupGoalCompleted) {
      BFApp.vent.trigger("show:signup:reminder");
      $.cookie("closedRegisterPopup", 1, {
        expires: 1
      });
    }

    if (this.signUpView && this.signUpView.allowClosePopup || !this.signUpView) {
      $("#r-popup .popup-layout").animate({
        "opacity": "0"
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingOut, function() {
        BFApp.popupRegion.close();
      });
    }

    // if they're closing the follow-confirmation popup, get rid of the URL hash
    // so they dont see the popup again if they refresh
    if (this.currentPopupView == "team-follow-confirmation") {
      if (window.location.hash == "#follow-confirm") {
        window.location.hash = "";
      }
    }

    // more of jacks nasty hacks (c)
    if ($("body").hasClass("paywall")) {
      $("body").removeClass("paywall");
      if (!ActiveApp.CurrentUser.isLoggedIn()) {
        BFApp.vent.trigger("change:state", {
          state: "follow"
        });
      }
    }

    this.currentPopupView = null;
  },

  showPopup: function(options) {
    this.listenTo(options.view, "close:popup", function() {
      this.closePopup();
    });

    this.showLayout(options.view, options.className, options.canClose, options);
  },

  signUp: function(params) {
    var signUpParams = $.extend({}, {
      model: ActiveApp.CurrentUser
    }, params);

    this.signUpView = new BFApp.Views.SignupPopup(signUpParams);

    this.listenTo(this.signUpView, "close:popup", function() {
      this.closePopup(false);
    });
    this.listenTo(this.signUpView, "show:login", function() {
      this.login(true, params);
    });
    this.listenTo(BFApp.vent, "register:successful", function() {
      if (ActiveApp.Tenant.get("page_options").team_followable) {
        var options;
        if (ActiveApp.ProfileTeam) {
          options = {
            teamName: ActiveApp.ProfileTeam.get('name'),
            actionType: 'joined'
          };
        } else {
          options = {};
        }
        this.downloadPopup(options);
      } else {
        window.location.reload();
      }
    });

    // default to allowClose = true
    var allowClose = ("allowClose" in params) ? allowClose : true;
    this.showLayout(this.signUpView, "five signup", allowClose);
    this.currentPopupView = "signup";
  },

  login: function(allowClosePopup) {
    var showSignup = true;
    // nasty paywall hack by jack
    if ($("body").hasClass('paywall')) {
      showSignup = false;
    }
    var loginView = new BFApp.Views.LoginForm({
      showSignup: showSignup
    });
    this.listenTo(loginView, "signup:clicked", function() {
      window.location.href = "/signup";
    });

    this.showLayout(loginView, "four", allowClosePopup);
    this.currentPopupView = "login";
  },

  teamOpenInviteLinkConfirmation: function(teamName) {
    var teamOpenInviteLinkConfirmationView = new BFApp.Views.TeamOpenInviteLinkConfirmationPopup({
      teamName: teamName
    });
    this.showLayout(teamOpenInviteLinkConfirmationView, "six", false);
    this.currentPopupView = "team-open-invite";
  },

  followTeam: function(options) {
    var followPopup, allowClose, popupColumns;
    if (options.paywall) {
      // paywall popup flow
      followPopup = new BFApp.Views.PaywallFlow(options);
      allowClose = false;
      popupColumns = "five";
    } else {
      allowClose = true;
      if (options.exitPopup) {
        // exit popup
        popupColumns = "five";
        followPopup = new BFApp.Views.FollowTeamPopupExit(options);
      } else {
        // normal follow team popup
        popupColumns = "seven";
        followPopup = new BFApp.Views.FollowTeamPopup(options);
      }
    }

    this.showLayout(followPopup, popupColumns + " follow-team-hack no-padding", allowClose);
    this.currentPopupView = "team-follow";

    this.listenTo(followPopup, "close:popup", function() {
      this.closePopup();
    });
  },

  downloadPopup: function(options) {
    var followStepPopup = new BFApp.Views.FollowStepsPopup(options);
    this.showLayout(followStepPopup, "seven no-padding no-close", true);
    this.currentPopupView = "download-app";
  },

  followTeamConfirmation: function(teamName) {
    var followConfirmation = new BFApp.Views.FollowTeamConfirmation({
      teamName: teamName
    });
    this.showLayout(followConfirmation, "six", true);
    this.currentPopupView = "team-follow-confirmation";
  },

  genericText: function(options) {
    var popupView = new BFApp.Views.TextPopup(options);
    this.showLayout(popupView, "six", true);
    this.currentPopupView = "generic-text";
  },

  eventRegisterForm: function(options) {
    var popupView = new BFApp.Views.EventRegisterFlow(options);
    // default to true
    var allowClose = (options && "allowClose" in options) ? allowClose : true;
    this.showLayout(popupView, "six extended-signup", allowClose);
    this.currentPopupView = "event-register-form";
  },

  leagueRegisterForm: function(options) {
    var popupView = new BFApp.Views.LeagueRegisterFlow(options);
    this.showLayout(popupView, "six extended-signup", true);
    this.currentPopupView = "league-register-form";
  },

  createDivisionForm: function(options) {
    var popupView = new BFApp.Views.CreateDivisionForm(options);
    this.showLayout(popupView, "six", true);
    this.currentPopupView = "create-division-form";
  },

  // currently used to create a new team on the RFU admin page, but should be used everywhere
  teamForm: function(options) {
    var teamForm;
    if (ActiveApp.Tenant.get("name") == "o2_touch") {
      teamForm = new BFApp.Views.O2TouchTeamForm(options);
    } else {
      teamForm = new BFApp.Views.MitooTeamForm(options);
    }
    this.showLayout(teamForm, "six", true);
    this.currentPopupView = "team-form";

    this.listenTo(teamForm, "team:edit:cancel", function() {
      this.closePopup();
    });
  },

  // currently just used for o2 touch
  leagueForm: function(options) {
    var leagueForm = new BFApp.Views.O2TouchLeagueForm(options);
    this.showLayout(leagueForm, "four", true);
    this.currentPopupView = "league-form";
  },

  claimLeagueForm: function(options) {
    var popupView = new BFApp.Views.ClaimLeaguePopup(options);
    this.showLayout(popupView, "seven no-padding", true);
    this.currentPopupView = "claim-league-form";
  },

  repeatEvents: function(numEvents) {
    var repeatEventsPopup = new BFApp.Views.RepeatEventsPopup({
      numEvents: numEvents
    });
    this.listenTo(repeatEventsPopup, "close:popup", function() {
      BFApp.vent.off("repeat-event-saved");
      this.closePopup();
    });
    this.showLayout(repeatEventsPopup, "five", false);
    this.currentPopupView = "repeat-events";
  }

});
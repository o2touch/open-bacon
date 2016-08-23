/**
 * This is used for the public team, div, league, club pages
 */
BFApp.Controllers.FaftProfile = Marionette.Controller.extend({

  setup: function() {
    var that = this;

    /* Listen to page state change (follow/download/share) */
    BFApp.vent.on("change:state", function(options) {
      that.changeState(options.state);
    });

    /* Add sidebar layout */
    this.rightSidebarLayout = new BFApp.Views.FaftRightSidebarLayout();
    BFApp.faftSidebar.show(this.rightSidebarLayout);

    // we dont want any of this shit if its not a followable (alien) team
    if (ActiveApp.Tenant.get("page_options").team_followable) {
      /* Show all those sidebar item  */
      this.showDownloadPanel();
      this.showFaftEmailClubPanel();

      if (ActiveApp.profileType != "league") {
        this.showGoalsPanel();
        this.showFaftFollowPanel();
        this.showFaftFollowSecondaryPanel();
      }
    }

    if (ActiveApp.ProfileTeam) {
      var clubId = ActiveApp.ProfileTeam.get("club_id");
      if (ActiveApp.Tenant.get("page_options").show_club_widget && clubId) {
        this.showClubPanel(clubId);
      }
    }

    var marketingPanel = ActiveApp.Tenant.get("page_options").show_marketing_copy_widget;
    if (marketingPanel) {
      this.showMarketingPanel(marketingPanel);
    }

    this.messyBind();
    if (ActiveApp.profileType !== "league") this.stickyNav();
  },

  showMarketingPanel: function(marketingPanel) {
    var layout = this.rightSidebarLayout.initMarketingCopyPanel();
    var view = new BFApp.Views[marketingPanel]();
    layout.showContent(view);
  },

  showClubPanel: function(clubId) {
    var that = this;

    var layout = this.rightSidebarLayout.initClubPanel();

    var club = new App.Modelss.Club({
      id: clubId
    });
    club.fetch({
      success: function(model) {
        that.onClubReady(model, layout);
      },
      error: function() {
        errorHandler();
      }
    });
  },

  onClubReady: function(club, layout) {
    var clubPanel = new BFApp.Views.ClubPanel({
      model: club
    });
    layout.showContent(clubPanel);
  },

  setupMapReadyListener: function() {

    // declare global showMap function, which will be called when gmaps api is loaded later
    window.showMap = function() {

      var address = null;
      // Note: on the club page, ActiveApp.ProfileDivision is a club lol
      if (ActiveApp.profileType == "club" && ActiveApp.ProfileDivision.get("address")) {
        address = ActiveApp.ProfileDivision.get("address");
      } else if (ActiveApp.profileType == "team" && ActiveApp.ProfileTeam.get("address")) {
        address = ActiveApp.ProfileTeam.get("address");
      } else if (ActiveApp.profileType == "league" && ActiveApp.ProfileLeague.get("location")) {
        address = ActiveApp.ProfileLeague.get("location").get("address");
      }

      if (address) {
        var geocoder = new google.maps.Geocoder();
        var latlng = new google.maps.LatLng(-34.397, 150.644);
        var mapOptions = {
          zoom: 15,
          center: latlng,
          disableDefaultUI: true,
          scrollwheel: false,
          navigationControl: false,
          mapTypeControl: false,
          scaleControl: false,
          draggable: false,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };

        var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
        geocoder.geocode({
          'address': address
        }, function(results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            map.setCenter(results[0].geometry.location);
            //   var marker = new google.maps.Marker({
            //     map: map,
            //     position: results[0].geometry.location
            // });

          } else {
            $(".location-module").remove();
          }
        });


      }
    };
  },

  /* Classic follow panel */
  showFaftFollowPanel: function() {
    var followPanel = new BFApp.Views.FaftFollowPanel();
    this.rightSidebarLayout.followPrimaryRegion.show(followPanel);
  },

  /* Secondary follow panel - with iphone image */
  showFaftFollowSecondaryPanel: function() {
    var followSecondaryPanel = new BFApp.Views.FaftFollowSecondaryPanel();
    this.rightSidebarLayout.followSecondaryRegion.show(followSecondaryPanel);
  },

  /* Tim's email club form */
  showFaftEmailClubPanel: function() {
    var emailClub = new BFApp.Views.FaftEmailClubPanel();
    this.rightSidebarLayout.emailRegion.show(emailClub);
  },

  /* Download the app panel */
  showDownloadPanel: function() {
    var downloadTheApp = new BFApp.Views.DownloadApp();
    this.rightSidebarLayout.downloadTheAppRegion.show(downloadTheApp);
  },

  /* Paywall setup */
  showPaywall: function() {
    var paywallFlowView = new BFApp.Views.PaywallFlow(window.followFormOptions);
    var popupOptions = {
      view: paywallFlowView,
      className: "five no-padding",
      canClose: false
    };
    BFApp.vent.trigger("popup:show", popupOptions);
  },

  /* Public Team Page Test 1: Mobile Download - See https://trello.com/c/12xk1RMY */
  showMobileDownloadAppPopup: function() {
    team = ActiveApp.ProfileTeam;
    console.log(team);
    var paywallFlowView = new BFApp.Views.MobileDownloadAppPopup({
      model: team
    });
    var popupOptions = {
      view: paywallFlowView,
      className: "full-screen download-test",
      canClose: false,
      centered: false,
      fullScreen: true
    };
    BFApp.vent.trigger("popup:show", popupOptions);
  },


  showGoalsPanel: function() {
    var goalsWidget = new BFApp.Views.FaftGoalPanel();
    this.rightSidebarLayout.goalsRegion.show(goalsWidget);

    goalsWidget.addGoal({
      position: 0,
      title: "Signup",
      dataTrigger: "show:form",
      dataTrack: "signup",
      percent: 30
    });

    goalsWidget.addGoal({
      position: 1,
      title: "Follow a team",
      dataTrigger: "show:form",
      dataTrack: "follow",
      percent: 30
    });

    goalsWidget.addGoal({
      position: 2,
      title: "Check out how Mitoo works",
      dataTrigger: "scroll:up",
      dataTrack: "onboarding",
      percent: 15
    });

    goalsWidget.addGoal({
      position: 3,
      title: "Download the iPhone or Android app",
      dataTrigger: "download:app",
      dataTrack: "download",
      percent: 15
    });

    goalsWidget.addGoal({
      position: 4,
      title: "Share with your team",
      dataTrigger: "show:facebook",
      dataTrack: "share",
      percent: 10
    });

    goalsWidget.on("show:form", function() {
      BFApp.vent.trigger("follow-team:show", followFormOptions);
    });

    goalsWidget.on("download:app", function() {
      BFApp.vent.trigger("download-app:show");
    });

    goalsWidget.on("show:facebook", function() {
      if (_.isFunction(facebookShareFunction)) {
        facebookShareFunction({
          callback: function() {
            goalsWidget.completeGoal(4);
          }
        });
      }
    });

    goalsWidget.on("scroll:up", function() {
      $(".open-close-onboarding").addClass("animate");
      $("html, body").animate({
        scrollTop: 0
      }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
    });

    /* If user is logged in, we consider that he at least signup & follow a team*/
    if (ActiveApp.CurrentUser.isLoggedIn()) {
      goalsWidget.completeGoal(0);
      goalsWidget.completeGoal(1);
    }

    /* if cookie is present */
    if ($.cookie("viewedFaftOnboarding")) {
      goalsWidget.completeGoal(2);
    }

    /* If user has login in the app Or if he clicked on the link on the past 2 days */
    if (ActiveApp.CurrentUser.hasDownloadedTheApp || $.cookie("hasClickedADownloadLinkRecently")) {
      goalsWidget.completeGoal(3);
    }

    /* if cookie is present */
    if ($.cookie("hasClickedAShareLinkRecently")) {
      goalsWidget.completeGoal(4);
    }

    /* General listener, so we can complete goal from template */
    BFApp.vent.on("goal:complete", function(options) {
      goalsWidget.completeGoal(options.goal);
    });

  },

  /* Will hide/show different region depending on page state */
  changeState: function(state) {
    state = 'download';
    $(".paywall-state-item, .follow-state-item, .download-state-item, .share-state-item").addClass("hide");
    switch (state) {
      case "paywall":
        $(".paywall-state-item").removeClass("hide");
        break;
      case "follow":
        $(".follow-state-item").removeClass("hide");
        break;
      case "download":
        $(".download-state-item").removeClass("hide");
        break;
      case "share":
        $(".share-state-item").removeClass("hide");
        break;
    }
  },

  /* 
  The code under here is a
  result of all kind of different binding
  we were doing on all faft page. It's
  ugly but at leat here we avoid repetition.

  A good solution for this would be to have one
  main faft template, which then select different
  partial (team/division/league/club).
  */
  messyBind: function() {
    this.setupMapReadyListener();


    $("body").on("click", "[name='register-team']", function() {
      BFApp.vent.trigger("league-register-form:show");
    });

    if (ActiveApp.Tenant.get("page_options").team_followable) {
      this.setupStoreLinkListeners();
      this.setupFollowLinkListeners();
      this.setupOnboardingDropdown();
      this.setupSearch();
    }

    if (ActiveApp.profileType == "league") {
      this.setupClaimLinkListeners();
    }

    this.setupShareListeners();
  },



  setupShareListeners: function() {

    var facebookShareFunction = function(options) {
      var customShare = facebookUIShare;
      if (!_.isUndefined(options) && _.isString(options.description)) {
        customShare.description = options.description;
      }
      FB.ui(customShare, function(response) {
        if (response && response.post_id) {
          analytics.track("Shared on facebook", analyticsObject);
          if (!_.isUndefined(options) && _.isFunction(options.callback)) {
            options.callback();
          }
        }
      });
    };

    var twitterShareFunction = function(url) {
      var opts = 'status=1' +
        ',width=' + 575 +
        ',height=' + 400 +
        ',top=' + (($(window).height() - 400) / 2) +
        ',left=' + (($(window).width() - 575) / 2);
      window.open(url, 'twitter', opts);
    }

    $('.share-button').click(function(event) {
      if ($(this).hasClass("facebook")) {
        analytics.track("Clicked share by facebook button", analyticsObject);
        facebookShareFunction();
      }

      if ($(this).hasClass("twitter")) {
        analytics.track("Clicked share by twitter button", analyticsObject);
        twitterShareFunction(twitterUrl);
      }
      return false;
    });

    $('.share-link').click(function(event) {
      if ($(this).hasClass("facebook")) {
        facebookShareFunction(facebookStatShare);
        analytics.track("Clicked share by facebook link", analyticsObject);
      }

      if ($(this).hasClass("twitter")) {
        twitterShareFunction(twitterUrlSecond);
        analytics.track("Clicked share by twitter link", analyticsObject);
      }
      return false;
    });

    $(".share-by-email").click(function() {
      analytics.track("Clicked share by email button", analyticsObject);
    });

    /* Share link - goals widget */
    $('.share-link, .share-button').click(function(event) {
      BFApp.vent.trigger("goal:complete", {
        goal: 4
      });
      $.cookie("hasClickedAShareLinkRecently", "true", {
        expires: 2
      });
    });
  },


  setupStoreLinkListeners: function() {
    /* Download the app metrics */
    $("body").on("click", ".store-link", function(e) {
      var downloadAnalytics = {
        "store": $(e.currentTarget).data("track"),
        "link_type": $(e.currentTarget).data("track-type")
      };
      if (ActiveApp.profileType != "league") {
        BFApp.vent.trigger("goal:complete", {
          goal: 3
        });
      }
      $.cookie("hasClickedADownloadLinkRecently", "true", {
        expires: 2
      });
      analytics.track("Clicked FAFT Download link", _.defaults(downloadAnalytics, analyticsObject));
      try {
        _gaq.push(['_trackEvent', 'Download Link', 'Download App', $(e.currentTarget).data("track")]);
      } catch (err) {}
    });
  },


  setupFollowLinkListeners: function() {
    /* Bind all follow link */
    $("body").on("click", ".follow-form", function(e) {
      e.preventDefault();
      var customAnalytics = {
        'button_type': $(e.currentTarget).attr("data-button-type")
      };
      _.defaults(customAnalytics, analyticsObject);
      analytics.track("Clicked FAFT follow popup button", customAnalytics);
      BFApp.vent.trigger("follow-team:show", followFormOptions);
    });
  },


  // bind all league claim links
  setupClaimLinkListeners: function() {
    $("body").on("click", ".js-claimLeague, .js-addLeagueDetails", function(e) {
      e.preventDefault();
      var target = $(e.currentTarget);
      var ctaType;
      if (target.hasClass("js-claimLeague")) {
        ctaType = "claim";
      } else if (target.hasClass("js-addLeagueDetails")) {
        ctaType = "add-details";
      } else {
        ctaType = "misc";
      }
      var customAnalytics = {
        cta_type: ctaType,
        cta: target.attr("data-track-join")
      };
      _.defaults(customAnalytics, analyticsObject);
      analytics.track("Clicked League Profile CTA", customAnalytics);
      BFApp.vent.trigger("claim-league-form:show");
    });
  },


  setupOnboardingDropdown: function() {

    /* Onboarding link ("how bluefields works") */
    if (BFApp.godbar.currentView) {
      $(".open-close-onboarding").hide();
    }

    var onboardingIsOpen = false;
    if (!$.cookie('viewedFaftOnboarding')) {
      $(".open-close-onboarding").addClass("animate");
    }
    $(".open-close-onboarding").click(function() {
      BFApp.vent.trigger("goal:complete", {
        goal: 2
      });
      if (!onboardingIsOpen) {
        BFApp.vent.trigger("show:onboarding");
        var onboardingView = new BFApp.Views.FaftOnboarding();
        BFApp.vent.trigger("show:godbar", {
          view: onboardingView,
          godbarClass: "bluefields-blue behind-content"
        });
        onboardingIsOpen = true;
        $(".open-close-onboarding").removeClass("animate");
        $(".open-close-onboarding i").removeClass("arrow-bottom").addClass("arrow-top");
        analytics.track("Open faft onboarding view");
      } else {
        BFApp.vent.trigger("hide:onboarding");
        $(".open-close-onboarding i").removeClass("arrow-top").addClass("arrow-bottom");
        onboardingIsOpen = false;
        BFApp.vent.trigger("hide:godbar");
        $("html, body").animate({
          scrollTop: 0
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);

        analytics.track("Close faft onboarding view");
      }
      $.cookie('viewedFaftOnboarding', true);
    });
  },


  setupSearch: function() {
    $(".team-search-form").submit(function() {
      var value = $(this).find("input").val();
      window.open('/search?q=' + value, '_newtab');
      return false;
    });
  },



  stickyNav: function() {
    var contentOneOffsetTop;
    var contentTwoOffsetTop;
    var contentThreeOffsetTop;
    var contentForOffsetTop;
    var containerHeight;
    var elementHeight = $(".content-navigation").outerHeight();

    var offsetTop;
    var offsetBottom;

    var $navigation = $(".content-navigation");
    var $parent = $(".content-sticky-navigation").parent();

    var updateVar = function() {
      offsetTop = $parent.offset().top - 75;
      containerHeight = $parent.height();
      var activeOffset = 120;
      offsetBottom = offsetTop + containerHeight - elementHeight;
      contentOneOffsetTop = ($(".tab-content:eq(0)").offset().top - activeOffset);
      contentTwoOffsetTop = ($(".tab-content:eq(1)").length > 0) ? ($(".tab-content:eq(1)").offset().top - activeOffset) : false;
      contentThreeOffsetTop = ($(".tab-content:eq(2)").length > 0) ? ($(".tab-content:eq(2)").offset().top - activeOffset) : false;
      contentForOffsetTop = ($(".tab-content:eq(3)").length > 0) ? ($(".tab-content:eq(3)").offset().top - activeOffset) : false;
    };

    var updateNavigation = function() {
      var documentScrollTop = $(document).scrollTop();
      $(".content-navigation a").removeClass("selected");
      if (contentForOffsetTop && documentScrollTop > contentForOffsetTop) {
        $(".content-navigation a:eq(3)").addClass("selected");
      } else if (contentThreeOffsetTop && documentScrollTop > contentThreeOffsetTop) {
        $(".content-navigation a:eq(2)").addClass("selected");
      } else if (contentTwoOffsetTop && documentScrollTop > contentTwoOffsetTop) {
        $(".content-navigation a:eq(1)").addClass("selected");
      } else {
        $(".content-navigation a:eq(0)").addClass("selected");
      }
    };

    var stickyNavigation = function() {
      var windowsScroll = $(window).scrollTop();
      var hasClassBottom = $(".content-sticky-navigation").hasClass("bottom");
      var hasClassFixed = $(".content-sticky-navigation").hasClass("fixed");
      var fixed = (windowsScroll > offsetTop && windowsScroll < offsetBottom && !hasClassFixed);
      var bottom = ((windowsScroll > offsetBottom || windowsScroll == offsetBottom) && !hasClassBottom);
      var normal = (windowsScroll < offsetTop && (hasClassFixed || hasClassBottom));

      if (fixed) {
        $(".content-sticky-navigation").removeClass("bottom").addClass("fixed");
        hasClassFixed = true;
      } else if (bottom) {
        $(".content-sticky-navigation").removeClass("fixed").addClass("bottom");
        hasClassBottom = true;
      } else if (normal) {
        $(".content-sticky-navigation").removeClass("fixed bottom");
      }
    };

    $(window).on("resize", function() {
      updateVar();
      updateNavigation();
    }).resize();

    $(window).on("scroll", function() {
      updateVar();
      updateNavigation();
      stickyNavigation();
    });

    $(".content-navigation a").click(function() {
      $("html, body").animate({
        scrollTop: $(".tab-content:eq(" + $(this).closest("li").index() + ")").offset().top - 90
      }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      return false;
    });
  }

});
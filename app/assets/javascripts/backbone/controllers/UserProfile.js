BFApp.Controllers.UserProfile = Marionette.Controller.extend({

  initialize: function(options) {
    this.options = options;

    this.firstRun = true;
  },

  setup: function(id) {

    // make sure help popup is closed
    if (!id && this.options.objUser) id = this.options.objUser.get("id");

    // if we're already setup and we've already loaded the right user then we're done
    if (this.isSetup && this.userModel && this.userModel.get("id") == id) {
      return;
    }

    // if we've already loaded a user's model, but now we're looking at a different profile page
    if (this.userModel && this.userModel.get("id") != id) this.onChangeUser();

    // Setup Main Layout
    this.mainLayout = new BFApp.Views.UserProfileLayout();
    BFApp.content.show(this.mainLayout);



    // Render Navigation
    var contentNaviView = new BFApp.Views.UserProfileNavi({
      id: id
    });
    this.mainLayout.contentNavi.show(contentNaviView);


    // Load userModel from data we already got from the server on page load
    if (this.firstRun && this.options.objUser && this.options.objUser.get("id") == id) {
      this.userModel = this.options.objUser;
      this.onModelReady(this.userModel);
      this.firstRun = false;
    } else {
      // Load userModel Async'ly
      this.userModel = App.Modelss.User.findOrCreate({
        id: id
      });
      this.userModel.fetch({
        success: _.bind(this.onModelReady, this)
      });
    }

    this.isSetup = true;
    this.isYourProfile = (ActiveApp.CurrentUser.get("id") == this.userModel.get("id"));
    return this.userModel.get("id");
  },



  onChangeUser: function() {
    this.firstRun = true;
    // mark for garbage collection
    this.activityCollection = null;
    this.scheduleCollection = null;
    this.pastGamesCollection = null;
  },

  /* User profile has been loaded */
  onModelReady: function(userModel) {

    this.showUserPanel(userModel);

    if ((!userModel.isJunior() || userModel.sharesTeamWithCurrentUser()) && ActiveApp.CurrentUser.isLoggedIn()) {
      this.showTeamPanel(userModel);
      // friends panel is for losers (also it's really inefficient on the BE and slows down the server)
      //this.showFriendsPanel(userModel);
    }

    if (ActiveApp.ProfileUserChildren.length > 0 && userModel.get("id") == ActiveApp.CurrentUser.get("id")) {
      this.showChildrenPanel();
    }

    this.trigger("user-profile:model-ready");
  },

  /* User profile details panel */
  showUserPanel: function(userModel) {
    var userDetailPanel = new BFApp.Views.UserDetailsPanel({
      model: userModel,
      showFacebookButton: ActiveApp.CurrentUser.get("fb_connected")
    });
    this.mainLayout.userProfile.show(userDetailPanel);
  },

  /* Childrens panel */
  showChildrenPanel: function() {
    this.mainLayout.initChildrenPanel();

    var childrenPanelView = new BFApp.Views.UsersListPanel({
      collection: ActiveApp.ProfileUserChildren
    });

    this.mainLayout.childrenPanelView.showContent(childrenPanelView);
  },

  /* Friends panel */
  showFriendsPanel: function(userModel) {
    var friendsCollection = new App.Collections.Users();
    var that = this;
    this.mainLayout.initFriendsPanel();
    this.mainLayout.friendsPanelView.showLoading();
    friendsCollection.fetch({
      data: $.param({
        user_id: userModel.get("id")
      }),
      success: function(collection, response, options) {
        if (collection.length > 0) {
          var friendsPanelView = new BFApp.Views.UsersListPanel({
            collection: collection
          });
          that.mainLayout.friendsPanelView.showContent(friendsPanelView);
        } else {
          that.mainLayout.friendsPanelView.close();
        }
      }
    });
  },

  /* Teams panel */
  showTeamPanel: function(userModel) {
    var that = this;

    this.mainLayout.initTeamPanel();
    var teamsCollection = new App.Collections.Teams();

    teamsCollection.fetch({
      data: $.param({
        user_id: userModel.get("id")
      }),
      success: function() {
        that.onTeamsReady(teamsCollection);
      },
      update: true
    });
  },

  onTeamsReady: function(teamsCollection) {
    var teamsPanelView = new BFApp.Views.TeamPanel({
      collection: teamsCollection,
      allowTeamCreation: (ActiveApp.ProfileUser.get("id") == ActiveApp.CurrentUser.get("id")),
    });
    this.mainLayout.teamPanelView.showContent(teamsPanelView);
  },


  showActivity: function(id) {

    // sometimes this will be called without an id e.g. from the route /dashboard
    var fetchedId = this.setup(id);
    if (!id) id = fetchedId;
    if (ActiveApp.Permissions.get("canViewProfileFeed")) {
      // clear this while we load the content
      this.mainLayout.content.show(new BFApp.Views.Spinner());

      // if we're looking at the original profile that we loaded the json data for on the first request
      var useJsonData = (id == ActiveApp.ProfileUser.get("id"));

      // first visit to activity tab
      if (!this.activityCollection) {

        // firstly we initialise the collection
        if (useJsonData) {
          this.activityCollection = ActiveApp.ProfileActivityItems;
        } else {
          this.activityCollection = new App.Collections.ActivityItems();
          this.activityCollection.context = "user";
        }

        // set the type
        var feedType;
        if (this.isYourProfile) {
          feedType = "newsfeed";
        } else {
          feedType = "profile";
        }

        // load the data
        if (useJsonData) {
          this.onActivityLoaded(this.activityCollection);
        } else {
          this.activityCollection.fetch({
            data: {
              feed_type: feedType,
              user_id: ActiveApp.ProfileUser.get("id")
            },
            success: _.bind(this.onActivityLoaded, this)
          });
        }
      } else this.onActivityLoaded(this.activityCollection);
    } else {
      var permDeniedView = new BFApp.Views.PermissionDenied({
        msg: "Only friends can view this user's feed!"
      });
      this.mainLayout.content.show(permDeniedView);
    }
  },

  onActivityLoaded: function(activityCollection) {
    if (activityCollection.length > 0) {
      var activityFeed = new BFApp.Views.ActivityItemList({
        collection: activityCollection,
      });
      this.mainLayout.content.show(activityFeed);
    } else {
      // empty activity
      var emptyView = new BFApp.Views.OverviewEmpty({
        isYourProfile: this.isYourProfile
      });
      this.mainLayout.content.show(emptyView);
    }

  },


  showSchedule: function(id) {
    this.setup(id);

    if (ActiveApp.Permissions.get("canViewProfileSchedule")) {
      //var scheduleView = new App.Views.UserProfileScheduleTab();
      this.scheduleLayout = new BFApp.Views.ScheduleLayout();
      this.mainLayout.content.show(this.scheduleLayout);



      // show spinner while we load the content
      this.scheduleLayout.loading.show(new BFApp.Views.Spinner());

      if (!this.scheduleCollection) {
        // if we're looking at the original profile that we loaded the json data for on the first request
        var useJsonData = (id == ActiveApp.ProfileUser.get("id"));
        if (useJsonData) {
          this.scheduleCollection = ActiveApp.Events;
          this.onScheduleLoaded(this.scheduleCollection);
        } else {
          this.scheduleCollection = new App.Collections.Events();
          this.scheduleCollection.fetch({
            data: $.param({
              user_id: id,
              when: "future"
            }),
            success: _.bind(this.onScheduleLoaded, this)
          });
        }
      } else this.onScheduleLoaded(this.scheduleCollection);

      // when we add a new event, re-render the schedule
      var that = this;
      this.scheduleCollection.bind("add", function() {
        that.onScheduleLoaded(this);
      });
    } else {
      var permDeniedView = new BFApp.Views.PermissionDenied({
        msg: "Only friends can view this user's schedule!"
      });
      this.mainLayout.content.show(permDeniedView);
    }
  },

  onScheduleLoaded: function(eventCollection) {
    this.scheduleLayout.loading.close();
    this.scheduleTabView = new BFApp.Views.ScheduleTab({
      collection: eventCollection
    });
    this.mainLayout.content.show(this.scheduleTabView);
  },

  showEditDetails: function(id) {
    this.listenTo(this, "user-profile:model-ready", function() {
      this.mainLayout.userProfile.currentView.showEdit();
    });

    this.showActivity(id);
  },

  showResults: function(id) {
    this.setup(id);

    if (ActiveApp.Permissions.get("canViewProfileSchedule")) {
      // clear this while we load the content
      this.mainLayout.content.show(new BFApp.Views.Spinner());

      if (!this.pastGamesCollection) {
        // if we're looking at the original profile that we loaded the json data for on the first request
        var useJsonData = (id == ActiveApp.ProfileUser.get("id"));
        if (useJsonData) {
          this.pastGamesCollection = ActiveApp.PastEvents;
          this.onResultsLoaded(this.pastGamesCollection);
        } else {
          this.pastGamesCollection = new App.Collections.PastEvents();
          this.pastGamesCollection.fetch({
            data: $.param({
              user_id: id,
              when: "past"
            }),
            success: _.bind(this.onResultsLoaded, this)
          });
        }
      } else this.onResultsLoaded(this.pastGamesCollection);
    } else {
      var permDeniedView = new BFApp.Views.PermissionDenied({
        msg: "Only friends can view this user's past games!"
      });
      this.mainLayout.content.show(permDeniedView);
    }
  },

  onResultsLoaded: function(resultsCollection) {
    this.resultsTabView = new BFApp.Views.ResultsTab({
      collection: resultsCollection
    });
    this.mainLayout.content.show(this.resultsTabView);
  },

  // we need a defaultRoute to handle the user entering an invalid hash
  defaultRoute: function() {
    window.location.hash = "";
  }

});
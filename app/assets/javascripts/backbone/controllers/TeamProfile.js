/**
 * Private team page
 */
BFApp.Controllers.TeamProfile = Marionette.Controller.extend({

  // cannot put this in initialize() as router would not be initialized yet
  setup: function(squadTab) {
    var that = this;

    if (!this.isSetup) {
      // on page load we remove this - it will get added again automatically if needed
      $.removeCookie("showGoalsWidget");

      // check for any action confirmation popups to display
      if (window.location.hash == "#follow-confirm") {
        BFApp.vent.trigger("follow-team-confirmation:show", ActiveApp.ProfileTeam.get("name"));
      }

      this.teamModel = ActiveApp.ProfileTeam;

      // Setup Main Layout
      this.mainLayout = new BFApp.Views.TeamProfileLayout();
      BFApp.content.show(this.mainLayout);


      this.showNavigation();

      // Header - team details
      var teamDetail = new BFApp.Views.ProfileTeamDetail({
        model: this.teamModel
      });

      this.mainLayout.header.show(teamDetail);

      // FSM - we need this even if we're starting in the complete state, in case the user
      // deletes enough events/players, in which case we need to show them state messages again
      if (ActiveApp.Permissions.get("canManageTeam")) {
        this.fsm = new BFApp.Controllers.TeamFsm();
        this.updateStateMessage();
        this.listenTo(ActiveApp.Events, "add remove", this.updateStateMessage);
        this.listenTo(ActiveApp.Teammates, "add remove reset", this.updateStateMessage);
      }

      // Goals Channel - Only for organisers
      if (ActiveApp.Permissions.get("canManageTeam")) {
        this.goalsCollection = ActiveApp.Goals;
        if (BFApp.Pusher) {
          var msgName = "team-" + ActiveApp.ProfileTeam.get("id") + "-goals";
          var channel = BFApp.Pusher.subscribe(msgName);
          this.goalsCollection.live({
            pusher: BFApp.Pusher,
            pusherChannel: channel,
            eventType: "goal"
          });
        }
      }

      // dont show RFU popup if they're invited and they get the signup popup (do that first, then they get this on refresh)
      if (ActiveApp.CurrentUser.get("needs_o2_fields") && !ActiveApp.CurrentUser.isInvited()) {
        BFApp.vent.trigger("event-register-form:show", {
          allowClose: false
        });
      }

      this.isSetup = true;
    }

    this.showSidebarPanels();
  },

  updateStateMessage: function() {
    // if we're not already showing a state msg
    // (either fresh page load, or going back from complete mode to incomplete mode)
    if (!this.stateMsgView) {
      // only display one if they're not already in the finished state
      this.fsm.updateState();
      if (!this.fsm.isComplete()) {
        this.showFsmMessage();
      }
    }
    // if we ARE already showing a state msg, only update it if there has been a state change
    else if (this.fsm.hasStateChange()) {
      this.showFsmMessage();
    }
  },

  showFsmMessage: function() {
    var tpl = this.fsm.getStateTemplate();
    this.stateMsgView = new BFApp.Views.FsmMessage({
      template: tpl
    });

    BFApp.vent.trigger("show:godbar", {
      view: this.stateMsgView,
      godbarClass: "bluefields-blue stripe fixed team-color"
    });

    // listen for the button click
    var that = this;
    this.listenTo(this.stateMsgView, "button:click", function() {
      var stateAction = that.fsm.getStateAction();
      // call the action as a function on the team controller
      if (typeof that[stateAction] === "function") {
        that[stateAction]();
      }
    });
  },



  /**
   * Goal oriented actions
   */

  addEvent: function() {
    this.pendingAddEvent = true;
    if (window.location.hash != "#schedule") {
      window.location.hash = "#schedule";
    } else {
      this.showSchedule();
    }
  },

  addPlayer: function() {
    window.location.hash = "#squad";
  },

  viewSchedule: function() {
    window.location.hash = "#schedule";
  },



  showSidebarPanels: function() {
    this.mainLayout.scheduleEdit.close();
    this.mainLayout.squadInformation.close();

    // Goals panel
    if (ActiveApp.Permissions.get("canManageTeam")) {
      this.showGoalsPanel();
    }

    // next game panel
    this.showNextGamePanel();

    // teammates panel
    this.showTeammatesPanel();

    if (ActiveApp.Tenant.get("name") == "o2_touch") {
      this.mainLayout.showO2TouchLinksPanel();
    }
  },


  showGoalsPanel: function() {
    var goalsPanel = new BFApp.Views.GoalsPanel({
      collection: this.goalsCollection
    });
    this.mainLayout.goals.show(goalsPanel);

    var that = this;
    this.listenTo(goalsPanel, "goal:clicked", function(stateAction) {
      // call the action as a function on the team controller
      if (typeof that[stateAction] === "function") {
        that[stateAction]();
      }
    });
  },


  showNextGamePanel: function() {
    var upcomingEvents = _.filter(ActiveApp.Events.models, function(e) {
      // dont show practices, or cancelled games
      return (!e.isPractice() && !e.isCancelled());
    });
    var nextEvent = _.first(upcomingEvents);
    var pastEvents = _.filter(ActiveApp.PastEvents.models, function(e) {
      return (!e.isPractice() && !e.isCancelled());
    });
    var lastEvent = _.first(pastEvents);

    if (nextEvent || lastEvent) {
      var panelContentView = new BFApp.Views.GameActivityPanel({
        nextEvent: nextEvent,
        lastEvent: lastEvent
      });
      this.mainLayout.initGameActivityPanel();
      this.mainLayout.gameActivityPanelView.showContent(panelContentView);
    }
  },


  showTeammatesPanel: function() {
    this.mainLayout.initTeammatesPanel();

    var teammatesCollection = new App.Collections.Users(ActiveApp.Teammates.filter(function(user) {
      return !user.isFollower(ActiveApp.ProfileTeam);
    }));

    var teammatesView;

    if (teammatesCollection.length > 0) {
      teammatesView = new BFApp.Views.UsersListPanel({
        collection: teammatesCollection
      });
    } else {
      teammatesView = new BFApp.Views.TeammatesEmptyView();
    }
    this.mainLayout.teammatesPanelView.showContent(teammatesView);
  },



  //	Tab 1: Activity
  showActivity: function() {
    var that = this;
    this.setup();

    if (ActiveApp.Permissions.get("canViewProfileFeed")) {
      var activityFeedView = new BFApp.Views.ActivityFeedTab({
        activityItemCollection: ActiveApp.ProfileActivityItems,
        // only organiser can post msgs on team page
        canPostMsg: ActiveApp.Permissions.get("canPostMessage"),
        isOrganiser: ActiveApp.Permissions.get("canManageTeam"),
        context: "team"
      });
      // Activity Item Channel
      if (BFApp.Pusher) {
        //var msgName = "activity_feed-profile-" + ActiveApp.ProfileTeam.get("id");
        var msgName = "team-" + ActiveApp.ProfileTeam.get("id") + "-activity";
        var msgChannel = BFApp.Pusher.subscribe(msgName);
        ActiveApp.ProfileActivityItems.live({
          pusher: BFApp.Pusher,
          pusherChannel: msgChannel,
          eventType: "activity_item"
        });
      }


      this.mainLayout.content.show(activityFeedView);

    } else {
      window.location.hash = "schedule";
    }
  },


  //	Tab 2: Schedule (we need to put tidy this)
  showSchedule: function() {

    this.setup();


    // proceed to next stage when current user responds
    this.listenTo(ActiveApp.Events, 'reset', function() {
      this.showSidebarPanels();
      this.showSchedule();
    });

    this.scheduleTabView = new BFApp.Views.ScheduleTab({
      collection: ActiveApp.Events
    });
    this.mainLayout.content.show(this.scheduleTabView);

    // listen out for clicks on edit-mode / view-mode
    this.listenTo(this.scheduleTabView, "add:event", this.addEventClicked);

    this.listenTo(this.scheduleTabView, "mode:edit", function() {
      // load list of current locations for this team's events
      if (!this.locations) {
        // disable button and load locations
        var button = this.scheduleTabView.scheduleNavigationView.ui.editButton;
        disableButton(button);
        this.locations = new App.Collections.Locations();
        var that = this;
        this.locations.getLocations("team", ActiveApp.ProfileTeam.get("id"), {
          success: function() {
            enableButton(button);
            that.locationsReady();
          }
        });
      } else {
        this.locationsReady();
      }

      analytics.track("Clicked Update Schedule");
    });

    this.listenTo(this.scheduleTabView, "mode:done", function() {
      this.scheduleDone();
      analytics.track("Clicked Update Schedule - Done");
    });

    if (this.pendingAddEvent) {
      this.pendingAddEvent = false;
      this.addEventClicked();
    }
  },

  locationsReady: function() {
    var that = this;

    var showAddEvent = (ActiveApp.Events.length === 0);
    this.enableScheduleEditMode(showAddEvent);

  },

  addEventClicked: function() {
    this.enableScheduleEditMode(true);
    analytics.track("Clicked Update Schedule - Add Event");
  },



  scheduleDone: function() {

    // if unsaved changes, alert user before continuing
    var discardChanges = true;
    if (this.editEventModel !== null && this.editEventModel.hasChanges()) {
      analytics.track("Update Schedule - Viewed Discard Changes Dialog");
      discardChanges = confirm("Discard unsaved changes?");
      // user wants to discard changes
      if (discardChanges) {
        this.editEventModel.restore();
        analytics.track("Update Schedule - Discard Changes - Clicked OK");
      } else {
        analytics.track("Update Schedule - Discard Changes - Clicked Cancel");
      }
    }

    if (discardChanges) {
      // removes any highlighting
      this.scheduleTabView.highlightEvent(null);

      // if there are changes, show the popup, else exit edit mode
      if (this.scheduleTabView.scheduleChange) {

        /*********************************
         * Change of plan
         * We're now just going to send the "send schedule" request here instead
         *********************************/

        $.ajax({
          type: "post",
          url: "/api/v1/teams/" + ActiveApp.ProfileTeam.get("id") + "/send_schedule",
          error: function() {
            errorHandler();
          }
        });

      }

      this.enableScheduleViewMode();
    }
  },

  // enable edit mode. send true or false for if you want to add a new event
  enableScheduleEditMode: function(addEvent) {
    var that = this;
    // the same newEvent is passed to the content and the sidebar to stay in sync
    var newEvent;
    if (addEvent) {
      // note: we need to set title and location here, to make all of the model.hasChanged() stuff work
      var newLocation = new App.Modelss.Location({
        title: ""
      });
      newEvent = new App.Modelss.Event({
        title: "",
        time_local: moment().add("days", 1).toCustomISO(),
        game_type_string: "game", // this is the default type, and gives the preview colours
        location: newLocation,
        team: this.teamModel
      });
    } else {
      newEvent = null;
    }

    // content
    this.scheduleTabView.enableEditMode(newEvent);

    // sidebar
    if (addEvent) {
      this.showEditEventForm(newEvent);
      this.scheduleTabView.highlightEvent(null);
    } else {

      this.mainLayout.initScheduleHelpTextPanel();
      var EditScheduleHelpTextPanelView = new BFApp.Views.EditScheduleHelpText();

      this.mainLayout.scheduleHelpTextPanel.showContent(EditScheduleHelpTextPanelView);

      sticky(this.mainLayout.scheduleHelpTextPanel.$el, $(".new-right-sidebar"));
      EditScheduleHelpTextPanelView.on("add:event", function() {
        that.enableScheduleEditMode(true);
      });
    }

    this.scheduleTabView.on("edit:event", function(eventModel) {
      this.newEventPreview.close();
      that.showEditEventForm(eventModel);
    });
  },

  showEditEventForm: function(eventModel) {
    this.editEventModel = eventModel;
    var eventEditView = new BFApp.Views.ScheduleEventEdit({
      model: eventModel,
      locations: this.locations
    });

    this.mainLayout.goals.close();
    this.mainLayout.teammates.close();
    this.mainLayout.scheduleEdit.show(eventEditView);

    var that = this;
    eventEditView.on("close:preview", function() {
      that.scheduleTabView.newEventPreview.close();
    });

    eventEditView.on("event:close", function() {
      that.editEventModel = null;
      that.enableScheduleEditMode(false);
      that.scheduleTabView.highlightEvent(null);
    });

    eventEditView.on("schedule:change", function() {
      that.scheduleTabView.scheduleChange = true;
    });

  },

  enableScheduleViewMode: function() {
    // content
    this.scheduleTabView.off("edit:event");
    this.scheduleTabView.enableViewMode();
    // sidebar
    this.showSidebarPanels();
  },


  /* Results Tab */
  showResults: function() {
    this.setup();
    this.resultsTabView = new BFApp.Views.ResultsTab({
      collection: ActiveApp.PastEvents
    });
    this.mainLayout.content.show(this.resultsTabView);
  },

  /* Squad Tab */
  showSquad: function() {
    this.setup(true);

    this.mainLayout.goals.close();
    this.mainLayout.nextGame.close();
    this.mainLayout.teammates.close();
    this.mainLayout.scheduleEdit.close();
    this.mainLayout.downloadApp.close();
    this.mainLayout.tenantSpecific.close();

    if (ActiveApp.Permissions.get("canViewPrivateDetails")) {
      var displayMode = "card";
      if (ActiveApp.Permissions.get("canManageTeam")) {
        displayMode = "list";
      }

      this.squadTabView = new BFApp.Views.SquadTab({
        collection: ActiveApp.Teammates,
        displayMode: displayMode,
        mainLayout: this.mainLayout
      });
      this.mainLayout.content.show(this.squadTabView);
    } else {
      window.location.hash = "schedule";
    }
  },

  // we require a defaultRoute function as the resulting route depends on the current state of affairs
  defaultRoute: function() {
    this.setup();

    // organiser on a brand new team (should start adding schedule)
    var isOrganiserNewTeam = (ActiveApp.CurrentUser.isTeamOrganiser(this.teamModel) && ActiveApp.Events.length === 0 && ActiveApp.PastEvents.length === 0);
    // guest (can't access activity content)
    var isGuest = (!ActiveApp.CurrentUser || !ActiveApp.CurrentUser.isLoggedIn());
    var isInTeam = ActiveApp.Permissions.get("canViewPrivateDetails");
    // player who has clicked "view schedule" in email
    var playerViewingSchedule = (ActiveApp.CurrentUser.isInvited() && isInTeam);

    if (isOrganiserNewTeam || isGuest || playerViewingSchedule) {
      Backbone.history.loadUrl("schedule");
    } else {
      Backbone.history.loadUrl("activity");
    }
  },

  /* Content navigation */
  showNavigation: function() {
    var contentNaviView = new BFApp.Views.TeamProfileNavi();
    this.mainLayout.contentNavi.show(contentNaviView);
  }

});
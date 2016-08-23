BFApp.Views.EventLayout = Marionette.Layout.extend({

  className: "event-page",

  template: "backbone/templates/event/event_layout",

  regions: {
    /* Header */
    headerMapView: "#r-map",
    gamecard: "#r-gamecard",

    /* Left columns */
    clubPanel: "#club-panel",
    result: "#result-container",
    response: "#response-container",
    teamsheet: "#teamsheet-container",
    gameStatus: "#game-status-container",

    /* Center columns */
    postMessage: "#r-post-message",
    organiserMessage: ".r-organiser-message",
    feed: ".r-feed",

    /* Right columns */
    actionPanel: "#action-container",
    informations: "#informations-container",
    sidebarMap: "#sidebar-map-container",
    reminders: "#reminders-container",
    dangerPanel: "#danger-container",

    /* Event tour */
    eventTour: "#event-tour"
  },


  onShow: function() {
    this.initInformationsPanel();

    if (BFApp.rootController.permissionsModel.can("canViewAllDetails")) {
      this.initTeamsheetPanel();
    }

    if (BFApp.rootController.permissionsModel.can("canEditEvent")) {
      this.initActionPanel();
    }
    if (BFApp.rootController.permissionsModel.can("canManageAvailability") && this.model.isOpen() && this.model.get("response_required")) {
      this.initRemindersPanel();
    }
  },

  initClubPanel: function() {
    this.clubPanelLayout = new BFApp.Views.PanelLayout({
      panelTitle: "Club",
      extendClass: "club-information-panel"
    });
    this.clubPanel.show(this.clubPanelLayout);
  },

  initResponsePanel: function(collection) {
    var alone = (collection.length == 1)
    this.responsePanelView = new BFApp.Views.PanelLayout({
      panelIcon: (alone) ? false : "check",
      panelTitle: (alone) ? false : "Availability",
      extendClass: (alone) ? "response" : "response-multi"
    });
    this.response.show(this.responsePanelView);

    if (collection.length == 1) {
      var responsePanelView = new BFApp.Views.ResponsePanel({
        model: collection[0]
      });
    } else {
      var responsePanelView = new BFApp.Views.MultiResponsePanel({
        collection: new App.Collections.TeamsheetEntries(collection),
        itemView: BFApp.Views.ResponseRow
      });
    }

    this.responsePanelView.showContent(responsePanelView);
  },

  initResultPanel: function() {
    this.resultPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "trophy",
      panelTitle: "Score",
      extendClass: "score"
    });
    this.result.show(this.resultPanelView);
  },


  initGameStatusPanel: function() {
    this.gameStatusPanelView = new BFApp.Views.PanelLayout({
      extendClass: "game-status"
    });
    this.gameStatus.show(this.gameStatusPanelView);
  },

  initRemindersPanel: function() {
    this.remindersPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "bell",
      panelTitle: "Reminders",
      extendClass: "reminders"
    });
    this.reminders.show(this.remindersPanelView);
  },

  initInformationsPanel: function() {
    this.informationPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "info",
      panelTitle: this.model.get("game_type_string") + " information",
      extendClass: "informations"
    });
    this.informations.show(this.informationPanelView);
  },

  initSidebarMapPanel: function() {
    var sidebarMapPanelView = new BFApp.Views.PanelLayout({
      panelTitle: "Map"
    });
    this.sidebarMap.show(sidebarMapPanelView);
    return sidebarMapPanelView;
  },

  /*initSharePanel: function() {
    this.sharePanelView = new BFApp.Views.PanelLayout({
      panelIcon: "chat",
      panelTitle: "Share",
      extendClass: "share"
    });
    this.share.show(this.sharePanelView);
  },*/

  initTeamsheetPanel: function() {
    this.teamsheetPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "users",
      panelTitle: "Teamsheet",
      extendClass: "teamsheet"
    });
    this.teamsheet.show(this.teamsheetPanelView);
  },

  initActionPanel: function() {
    this.actionPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "cog",
      panelTitle: "Actions",
      extendClass: "action-panel"
    });
    this.actionPanel.show(this.actionPanelView);
  },

  initDangerPanel: function() {
    this.dangerPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "eye",
      panelTitle: "Danger zone",
      extendClass: "danger"
    });
    this.dangerPanel.show(this.dangerPanelView);
  }

});
BFApp.Routers.TeamProfile = Marionette.AppRouter.extend({

  appRoutes: {
    // we may need this in the future for public team pages
    //"open-invite": "showOpenInvitePopup",
    "activity": "showActivity",
    "results": "showResults",
    "schedule": "showSchedule",
    "squad": "showSquad",
    "*path": "defaultRoute",
  }

});
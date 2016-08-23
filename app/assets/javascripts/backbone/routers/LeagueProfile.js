BFApp.Routers.LeagueProfile = Marionette.AppRouter.extend({

  appRoutes: {
    "divisions/:dId/results(/)": "showResults",
    "divisions/:dId/schedule(/)": "showSchedule",
    "divisions/:dId/message(/)": "showMessages",
    "divisions/:dId/teams(/)": "showTeams",
    "divisions/:dId/members(/)": "showMembers",
    "divisions/:dId(/)": "showSchedule",
    // this will redirect to the first division in the list
    "*path": "showSchedule"
  }

});
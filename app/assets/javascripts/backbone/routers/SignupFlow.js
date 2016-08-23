SFApp.Routers.SignupFlow = Marionette.AppRouter.extend({

  appRoutes: {
    "step1": "showTeam",
    "step2": "showOrganiser",
    "step3": "showFacebook",
    "confirmation": "showConfirmation",
    "": "showTeam"
  }

});
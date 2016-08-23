BFApp.Routers.UserProfile = Marionette.AppRouter.extend({

  appRoutes: {
    "user/:id/activity": 'showActivity',
    "user/:id/edit": 'showEditDetails',
    "user/:id/schedule": 'showSchedule',
    "user/:id/results": 'showResults',
    "user/:id": 'showActivity',
    "": 'showActivity',
    "*path": "defaultRoute" // Backbone will try match the route above first
  }
  
});
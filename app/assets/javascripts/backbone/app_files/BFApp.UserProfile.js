BFApp.module('UserProfile', {

  startWithParent: false,

  define: function(UserProfile, App, Backbone, Marionette, $, _) {

    UserProfile.addInitializer(function(options) {

      //console.log("UserProfileModule::Initializer");
      //console.log(options);

      var userProfileController = new BFApp.Controllers.UserProfile(options);
      this.router = new BFApp.Routers.UserProfile({
        controller: userProfileController
      });

      //console.log("Started UserProfile Module - starting history");
      Backbone.history.start();
    });

  }

});
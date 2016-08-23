BFApp.module('TeamProfile', {

  startWithParent: false,

  define: function(TeamProfile, App, Backbone, Marionette, $, _){
    
    TeamProfile.addInitializer(function(options){

      //console.log("TeamProfileModule::Initializer");
      //console.log(options);

      var teamProfileController = new BFApp.Controllers.TeamProfile(options);
      this.router = new BFApp.Routers.TeamProfile({
        controller: teamProfileController
      });
      
      
      
      //console.log("Started TeamProfile Module - starting history");
      Backbone.history.start();
    });

  }

});
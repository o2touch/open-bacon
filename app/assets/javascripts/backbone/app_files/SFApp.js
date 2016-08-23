// Signup Flow App
var SFApp = new Backbone.Marionette.Application();

// Namespacing
_.extend(SFApp, {
  Controllers: {},
  Models: {},
  Views: {},
  Routers: {}
});

// App Regions
SFApp.addRegions({
  content: "#r-module",
  footer:"#r-footer"
});

SFApp.addInitializer(function() {

  //console.log("SFApp::Initializer");

  var signupFlowController = new SFApp.Controllers.SignupFlow();
  this.router = new SFApp.Routers.SignupFlow({
    controller: signupFlowController
  });

    
  

  //console.log("Started SignupFlow Module - starting history");
  Backbone.history.start();
});
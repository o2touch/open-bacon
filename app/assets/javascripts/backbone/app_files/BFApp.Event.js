BFApp.module('Event', {

  startWithParent: false,

  define: function(Event, App, Backbone, Marionette, $, _) {

    Event.addInitializer(function(options) {

      var controller = new BFApp.Controllers.Event();

      // currently the router is only used to catch the empty hash event
      // when we close the help popup
      new BFApp.Routers.Event({
        controller: controller
      });

      //console.log("Started Event Module");
      Backbone.history.start();
    });

  }

});
BFApp.module('Godbar', {

  startWithParent: true,

  define: function(Popup, App, Backbone, Marionette, $, _) {
    Popup.addInitializer(function() {
      
      /* Godbar controller, Godbar.js */
      var controller = new BFApp.Controllers.Godbar();

      /* 
        Show godbar: options are: 
          view: backbone view
          godbarClass: classe(s) to add on the layout)
      */
      BFApp.vent.on("show:godbar", function(options) {
        controller.showGodbar(options);
      });

      /* 
        Hide godbar: options are: 
          callback: function to execute to the end of animation
      */
      BFApp.vent.on("hide:godbar", function(options) {
        controller.hideGodbar(options);
      });

      /* classic alert */
      BFApp.vent.on("alert:godbar", function(options) {

        var godbarAlert = {};

        var alert = new BFApp.Views.GodbarAlert({
          message: options.message,
          icon: options.icon,
          explanation: options.explanation
        });

        godbarAlert.view = alert;
        godbarAlert.godbarClass = options.type;
        controller.showGodbar(godbarAlert);

      });


    });
  }

});
/*
 * BFApp Help Controller
 * This is the help controlelr
 */
var BFApp, Marionette, console;

BFApp.Controllers.Admin = Marionette.Controller.extend({

  view: null,

  initialize: function(options) {
    this.options = options;

    this.parentView = options.parentView ? options.parentView : null;
  },
});
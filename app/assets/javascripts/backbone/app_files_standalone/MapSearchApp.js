/**
 * Event Search widget app
 *
 * This must be in app_files_standalone/ because the main application.js has a catch-all on
 * app_files/ and this file conflicts with the main ABFApp.js (both declare the BFApp global)
 */

var BFApp = new Backbone.Marionette.Application();

// Namespacing
_.extend(BFApp, {
  Controllers: {},
  Views: {}
});

// App Regions
BFApp.addRegions({
  map: "#r-map",
  searchPanel: "#r-search-panel"
});

BFApp.addInitializer(function(options) {
  var controller = new BFApp.Controllers.MapSearch(options);
  controller.setup();
});


// app functions
_.extend(BFApp, {

  // provide a jquery object for the container, and the template and data to render into it
  renderTemplate: function(container, template, data) {
    var html = this.renderHtml("backbone/templates/" + template, data);
    container.append(html);
  },

  renderHtml: function(template, data) {
    if (!JST[template]) throw "Template '" + template + "' not found!";
    return JST[template](data);
  }

});

/* Marionette Template Setup */
Marionette.Renderer.render = BFApp.renderHtml;
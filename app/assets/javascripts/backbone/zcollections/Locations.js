App.Collections.Locations = Backbone.Collection.extend({

  model: App.Modelss.Location,

  getLocations: function(type, id, options) {
    options.url = "/api/v1/locations?resource=" + type + "&resource_id=" + id;
    this.fetch(options);
  },

});
App.Modelss.Ability = Backbone.Model.extend({

  can: function(permission) {
    return (this.get(permission) !== undefined && this.get(permission) === true)
  },

  sync: function(method, model, options) {
    options = options || {};
    url = "/events";
    if (method != "create") {
      url += "/" + ActiveApp.Event.get("id") + "/permissions.json";
    } else {
      url += "/permissions.json";
    }
    options.url = url;

    Backbone.sync(method, model, options);
  }
});
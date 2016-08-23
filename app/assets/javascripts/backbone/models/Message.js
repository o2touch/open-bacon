App.Modelss.Message = App.Modelss.ActivityItemObject.extend({

  parse: function(response) {
    // Backbone Relational stores all ActivityItemObject models together, so we differentiate them
    // by including their type in the ID
    response.relationalId = "message" + response.id;

    return response;
  },

  url: function() {
    return '/api/v1/messages';
  },

  toJSON: function() {
    return {
      message: _.clone(this.attributes)
    };
  },

  getType: function() {
    return this.get("messageable_type").toLowerCase();
  },

  sync: function(method, model, options) {
    options = options || {};

    if (method == "create") {
      this.unset("created_at");
    }

    options.url = this.url();
    Backbone.sync(method, model, options);
  }

});
App.Collections.Teams = Backbone.Collection.extend({

  model: App.Modelss.Team,

  url: function() {
    return "/api/v1/teams";
  },

  comparator: function(model) {
    return model.get("name").toLowerCase();
  }

});
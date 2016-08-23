App.Modelss.TeamRole = Backbone.RelationalModel.extend({

  url: function() {
    return "/api/v1/team_roles" + (this.get("id") ? "/" + this.get("id") : "");
  },

  toJSON: function() {
    return {
      team_role: _.clone(this.attributes)
    }
  }

});
App.Modelss.TeamInvite = Backbone.RelationalModel.extend({
  initialize: function() {

  },

  toJSON: function() {
    return {
      team_invite: _.clone(this.attributes)
    }
  }
});
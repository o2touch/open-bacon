var AppBase = {
  isType: function(type) {
    return type == this.type;
  }
}

var AppTypes = {
  UserProfile: "UserProfile",
  TeamProfile: "TeamProfile"
}

AppBase.vent = _.extend({}, Backbone.Events);
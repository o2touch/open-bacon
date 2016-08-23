BFApp.Views.PlayerSignupReminder = Marionette.ItemView.extend({

  className: "",

  template: "backbone/templates/common/godbar/player_signup_reminder",

  events: {
    "click button[name='signup']": "clickedSignup"
  },

  serializeData: function() {
    return {
      name: this.model.get('name')
    };
  },

  onRender: function(){
    BFApp.vent.on("register:successful", function() {
      BFApp.vent.trigger("hide:godbar");
    });
  },

  clickedSignup: function() {
    BFApp.vent.trigger("signup-popup:show");
  }

});
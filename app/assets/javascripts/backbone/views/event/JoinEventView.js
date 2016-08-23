BFApp.Views.JoinEventView = Marionette.ItemView.extend({

  template: "backbone/templates/event/join_event",

  className: 'join-event-text',

  ui: {
    joinButton: "button[name=join]"
  },

  events: {
    "click button[name=join]": "joinEvent"
  },

  joinEvent: function() {
    BFApp.vent.trigger("event-register-form:show");
  }

});
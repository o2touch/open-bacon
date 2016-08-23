BFApp.Views.EventActivatedActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/event_activated",

  initialize: function(options) {
    this.context = options.context;
  },

  serializeData: function() {
    return {
      user: this.model.get("subj"),
      isEventPage: (this.context == "event"),
      event: this.model.get("obj")
    };
  }

});
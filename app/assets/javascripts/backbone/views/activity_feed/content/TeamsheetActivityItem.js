BFApp.Views.TeamsheetActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/teamsheet_entry_added_to",

  initialize: function(options) {
    this.context = options.context;
  },

  serializeData: function() {
    return {
      user: this.model.get("subj"),
      isEventPage: (this.context == "event"),
      event: this.model.get("obj").get("event")
    };
  }

});
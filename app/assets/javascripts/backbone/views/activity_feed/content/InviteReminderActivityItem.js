BFApp.Views.InviteReminderActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/invite_reminder_sent",

  initialize: function(options) {
    this.context = options.context;
  },

  serializeData: function() {
    return {
      user: this.model.get("subj"),
      isEventPage: (this.context == "event"),
      event: this.model.get("obj").get("teamsheet_entry").get("event")
    };
  }

});
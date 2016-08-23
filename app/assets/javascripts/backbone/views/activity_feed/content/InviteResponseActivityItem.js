BFApp.Views.InviteResponseActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/invite_response_created",

  initialize: function(options) {
    this.context = options.context;
  },

  serializeData: function() {
    return {
      user: this.model.get("subj"),
      isAttending: (this.model.get("obj").get("response_status") == 1),
      isEventPage: (this.context == "event"),
      event: this.model.get("obj").get("teamsheet_entry").get("event")
    };
  }

});
BFApp.Views.EventResultActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/event_result_updated",

  initialize: function(options) {
    this.context = options.context;
  },

  serializeData: function() {
    var updates = $.parseJSON(this.model.get("meta_data"));

    return {
      user: this.model.get("subj"),
      isEventPage: (this.context == "event"),
      event: this.model.get("obj").get("event"),
      scoreFor: updates['score_for'][1],
      scoreAgainst: updates['score_against'][1]
    };
  }

});
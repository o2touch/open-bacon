BFApp.Views.EventCreatedActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/event_created",

  ui: {
    eventPreview: ".event-preview"
  },

  serializeData: function() {
    return {
      user: this.model.get("subj"),
      isEventPage: (this.options.context == "event"),
      eventType: this.model.get("obj").get("game_type_string")
    };
  },

  onRender: function() {
    var eventRow = new BFApp.Views.EventRow({
      model: this.model.get("obj")
    });
    this.ui.eventPreview.append(eventRow.render().$el);
  }

});
BFApp.Views.GameActivityPanel = Marionette.Layout.extend({

  template: "backbone/templates/panels/game_activity_panel/game_activity_panel",

  regions: {
    nextEvent: ".future",
    lastEvent: ".past"
  },

  onShow: function() {
    if (this.options.nextEvent) {
      var nextEventCard = new BFApp.Views.EventRow({
        model: this.options.nextEvent
      });
      this.nextEvent.show(nextEventCard);
      this.nextEvent.$el.prev('.event-activity-title').removeClass('hide');
    }

    if (this.options.lastEvent) {
      var lastEventCard = new BFApp.Views.EventRow({
        model: this.options.lastEvent
      });
      this.lastEvent.show(lastEventCard);
      this.lastEvent.$el.prev('.event-activity-title').removeClass('hide');
    }
  }

});
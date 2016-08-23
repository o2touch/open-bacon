BFApp.Views.RepeatEventsPopup = Marionette.ItemView.extend({

  template: "backbone/templates/popups/repeat-events-popup",
  className: "repeat-events-popup",

  ui: {
    "eventCount": ".event-count"
  },

  initialize: function(options) {
    this.numEvents = options.numEvents;
    this.savedEvents = 0;

    var that = this;
    BFApp.vent.on("repeat-event-saved", function() {
      that.savedEvents++;
      // if finished saving the last event
      if (that.savedEvents == that.numEvents) {
        that.trigger("close:popup");
      } else {
        var currentlySavingEvent = that.savedEvents+1;
        that.ui.eventCount.text(currentlySavingEvent);
      }
    });
  },

  serializeData: function() {
    return {
      numEvents: this.numEvents
    };
  },

  onRender: function() {
    this.$(".spinner").spin({
      width: 6,
      radius: 30,
      corners: 1,
      color: '#333',
      top: 'auto',          
      left: 'auto', 
    });
  }

});
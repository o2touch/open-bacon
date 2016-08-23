BFApp.Views.ExportEventCalendarForm = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/schedule/export_event_calendar",
  className: "schedule-notification clearfix",


  events: {
    'click .export-link': 'showExportCalendar',
  },

  showExportCalendar: function() {
    var calendarView = new BFApp.Views.ExportCalendar({
      model: this.model
    });
    BFApp.vent.trigger("popup:show", {
      view: calendarView,
      className: "new-popup seven",
      canClose: true
    });
    analytics.track('Clicked Dashboard - Export Calendar', {});
    return false;
  },

  disable: function() {
    this.$el.animate({
        'opacity': 0.5
      },
      BFApp.constants.animation.time, BFApp.constants.animation.easingIn
    );
    this.$el.css("pointer-events", "none");
  },

  enable: function() {
    this.$el.animate({
        'opacity': 1
      },
      BFApp.constants.animation.time, BFApp.constants.animation.easingOut
    );
    this.$el.css("pointer-events", "all");
  },

});
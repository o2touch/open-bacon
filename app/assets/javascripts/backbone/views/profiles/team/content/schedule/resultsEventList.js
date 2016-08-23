BFApp.Views.ResultsEventList = Marionette.CompositeView.extend({

  className: "schedule-date",

  template: "backbone/templates/profiles/team/content/results/results_event_list",

  itemView: BFApp.Views.ResultsEventRow,
  // itemView: BFApp.Views.EventRow,

  appendHtml: function(collectionView, itemView, index) {
    var eventTime = itemView.model.getMyLocalisedDateObj(),
      startOfWeek = moment().startOf("week");

    if (eventTime.isBefore(startOfWeek)) {
      collectionView.$el.find(".past-week").removeClass("hide").append(itemView.el);
    } else {
      collectionView.$el.find(".past-event").removeClass("hide").append(itemView.el);
    }
  },

  onRender: function() {
    // make placeholders work in shit browsers
    this.$('input, textarea').placeholder();
  }

});
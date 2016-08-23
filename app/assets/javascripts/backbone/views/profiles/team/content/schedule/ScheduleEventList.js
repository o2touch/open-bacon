/**
 * Displays events grouped by time periods
 */
BFApp.Views.ScheduleEventList = Marionette.CompositeView.extend({

  className: "schedule-date",

  template: "backbone/templates/profiles/team/content/schedule/event_panel",

  emptyView: BFApp.Views.TeamScheduleEmpty,

  itemView: BFApp.Views.ScheduleEventRow,
  // itemView: BFApp.Views.EventRow,


  initialize: function(options) {
    // hack to get empty sections to hide again after you remove their last item
    this.listenTo(this.collection, 'remove', this.render);
  },

  itemViewOptions: function() {
    return {
      originalCollection: ActiveApp.Events
    };
  },

  setCollection: function(c) {
    this.collection = c;
    this.render();
  },

  // this hackish way of adding events to the list and un-hiding groups
  // only works by re-rendering everything all the time
  appendHtml: function(collectionView, itemView, index) {
    if (this._showingEmptyView) {
      collectionView.$el.find(".upcoming, .this-week, .next-week, .empty").addClass("hide");
      collectionView.$el.find(".empty").removeClass("hide").append(itemView.el);
      return;
    }

    var eventTime = itemView.model.getMyLocalisedDateObj();
    var endOfThisWeek = moment().endOf("week");
    var endOfNextWeek = moment().endOf("week").add("weeks", 1);

    // hide the empty message
    collectionView.$el.find(".empty").addClass("hide");

    if (eventTime < endOfThisWeek) {
      collectionView.$el.find(".this-week").removeClass("hide").append(itemView.el);
    } else if (eventTime < endOfNextWeek && eventTime >= endOfThisWeek) {
      collectionView.$el.find(".next-week").removeClass("hide").append(itemView.el);
    } else if (eventTime >= endOfNextWeek) {
      collectionView.$el.find(".upcoming").removeClass("hide").append(itemView.el);
    }
  }

});
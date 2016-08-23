/**
 * Activity item list on the Team and Event page
 */
BFApp.Views.ActivityItemList = Marionette.CollectionView.extend({

  tagName: "ul",

  itemView: BFApp.Views.ActivityItemLayout,

  itemViewOptions: function() {
    return {
      context: this.options.context,
      collection: this.collection,
      isOrganiser: this.options.isOrganiser
    };
  },

  initialize: function() {
    this.el.id = "activity-feed";
    this.listenTo(this.collection, "change relational:reset relational:add", this.render);
  },

  /*appendHtml: function(collectionView, itemView, index) {
    // remember to check for empty
    if (this._showingEmptyView ||
      (itemView.model.get("obj") !== null && itemView.model.get("subj") !== null)) {
      try {
        collectionView.$el.append(itemView.el);
      } catch(err) {
        analytics.track(
          'Bad Activity Item',
          {
            user_id: ActiveApp.CurrentUser.get("id"),
            activity_item_id: itemView.model.get("id")
          }
        );
      }
    }
  },*/

  onRender: function() {
    this.$("input, textarea").placeholder();
    this.$el.find(".starred").last().addClass("last-starred")
  }

});
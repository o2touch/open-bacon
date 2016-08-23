/**
 * Activity feed tab on the Team and Event page
 */
BFApp.Views.ActivityFeedTab = Marionette.Layout.extend({

  template: "backbone/templates/activity_feed/activity_feed_layout",

  regions: {
    messageForm: ".r-message-form",
    activityList: ".r-activity-list"
  },


  initialize: function(options) {
    this.activityItemCollection = options.activityItemCollection;
    this.context = options.context;
    if (this.context == "team" || this.context == "league") {
      this.$el.addClass("main-content");
    }
  },

  onRender: function() {
    // activity items
    var emptyView;
    if (this.context == "event") {
      emptyView = BFApp.Views.EventActivityEmpty;
    } else if (this.context == "team") {
      emptyView = BFApp.Views.TeamActivityEmpty;
    }
    var activityFeedView = new BFApp.Views.ActivityItemList({
      collection: this.activityItemCollection,
      emptyView: emptyView,
      context: this.context,
      isOrganiser: this.options.isOrganiser
    });
    this.activityList.show(activityFeedView);


    // Post message form
    if (this.options.canPostMsg) {
      var createMessageView = new BFApp.Views.ActivityMessageWidget({
        context: this.context,
        isOrganiser: this.options.isOrganiser,
        divisionId: this.options.divisionId
      });
      this.messageForm.show(createMessageView);
      this.listenTo(createMessageView, "add:message", this.addMessage);
    }
  },

  // temporarily add a message placeholder to the activity feed while we wait for pusher
  addMessage: function(msgModel) {
    // set the created_at time to that of the message
    // (to order the collection, and to say "just now" on the activity item)
    var messageActivityItem = new App.Modelss.ActivityItem({
      "placeholder": true,
      "subj_type": "User",
      "obj_type": "EventMessage",
      "verb": "created",
      "created_at": msgModel.get("created_at"),
      "subj": ActiveApp.CurrentUser,
      "obj": msgModel,
      // we dont yet have access to the true starred_at value, so use created_at for now
      "starred_at": (msgModel.get("starred")) ? msgModel.get("created_at") : false
    });
    this.activityItemCollection.add(messageActivityItem);
  },

});
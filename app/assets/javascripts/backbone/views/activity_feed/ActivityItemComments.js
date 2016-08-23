BFApp.Views.ActivityItemComments = Marionette.CompositeView.extend({

	className: "activity-item-comments",

  template: "backbone/templates/activity_feed/activity_item_comment_list",
	
	itemView: BFApp.Views.ActivityItemComment,

  ui: {
    commentList: ".comment-list",
    showAllButton: ".btn-show-all-comments",
    showAllText: ".show-all-text",
    showAllButtonContainer: ".show-all-container"
  },

  events: {
    "click .btn-show-all-comments": "clickedShowAll"
  },

  initialize: function() {
    this.firstRun = true;
  },

  appendHtml: function(collectionView, itemView, index) {
    this.$(".comment-list").append(itemView.el);
  },

  clickedShowAll: function() {
    this.showAllComments();
    // tell the parent to show the comment form
    this.trigger("show:all", true);
    return false;
  },

  showAllComments: function() {
    this.$(".comment").removeClass("hide");
    this.ui.showAllButtonContainer.remove();
  },

  onRender: function() {
    if (this.firstRun) {
      this.firstRun = false;
      var text, collapse = false;
      // hide comments on starred items
      if (this.options.starred && this.collection.length) {
        collapse = true;
        text = "Show comments ("+this.collection.length+")";
        this.$(".comment").addClass("hide");
      }
      // limit comments to 2
      else if (this.collection.length > 2) {
        collapse = true;
        var numOthers = this.collection.length - 2;
        text = "Show "+numOthers+" other comments";
        this.ui.commentList.find(".comment:lt(" + numOthers + ")").addClass("hide");
      }
      if (collapse) {
        this.ui.showAllText.text(text);
        this.ui.showAllButtonContainer.removeClass("hide");
      }
    }
  }

});
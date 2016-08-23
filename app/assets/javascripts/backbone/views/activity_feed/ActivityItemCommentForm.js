BFApp.Views.ActivityItemCommentForm = Marionette.ItemView.extend({
	
	tagName: "div",

	className: "activity-comment-form",
	
	template: "backbone/templates/activity_feed/activity_item_comment_form",

	initialize: function(options) {
		if (!options.show) {
			this.$el.addClass("hide");
		}
	},

	serializeData: function() {
		return {
			htmlPic: ActiveApp.CurrentUser.getPictureHtml("thumb")
		};
	}

});

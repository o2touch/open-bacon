/**
 * Displays fixtures grouped by time periods (used on both schedule and results tabs)
 */
BFApp.Views.ScheduleFixtureList = Marionette.CollectionView.extend({

	className: "fixtures-list",

	initialize: function(options) {
		// hack to get empty sections to hide again after you remove their last item
		this.listenTo(this.collection, 'remove', this.render);
		if (options.viewingEdits && options.showFutureFixtures) {
			this.$el.addClass("edit-mode");
		}

		this.ld = options.ld;
	},

	itemViewOptions: function() {
		// for empty view
		if (this.collection.length == 0) {
			return {
				showFutureFixtures: this.options.showFutureFixtures,
			};
		} else {
			return {
				ld: this.ld
			}
		}
	},

	onBeforeRender: function() {
		this.currentDataElem = [];
		this.$el.find(".fixtures-group").remove();
	},

	appendHtml: function(collectionView, itemView, index) {
		if (this._showingEmptyView) {
			this.$el.append(itemView.el);
			return;
		} 
		var date = itemView.model.getDateObj();
		if (date) {
			var dateID = date.format("YYYY-MM-DD");
			if (!_.contains(this.currentDataElem, dateID)) {
				BFApp.renderTemplate(this.$el, "partials/fixture-group-date", {
					dateId: dateID,
					day: date.date(),
					month: date.format("MMM")
				});
				this.currentDataElem.push(dateID);
			}
			this.$el.find("#" + dateID).append(itemView.el);
		} else {
			this.$el.append(itemView.el);
		}
	},

	setCollection: function(c) {
		this.collection = c;
		this.render();
	},

});
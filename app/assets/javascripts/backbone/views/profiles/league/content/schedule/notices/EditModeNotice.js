BFApp.Views.EditModeNotice = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/league/content/schedule/notices/edit_mode_notice",

	className: "schedule-navigation classic clearfix",

	events: {
		"click button": "viewEdits"
	},

	ui: {
		"button": "button"
	},

	initialize: function(options) {
		this.ld = options.ld;
	},

	serializeData: function() {
		return {
			hasUnpublishedEdits: (this.ld.division.get("edit_mode") == 1)
		};
	},

	viewEdits: function() {
		var that = this;
		disableButton(this.ui.button);
		
		this.ld.division.fetchDivisionWithFixtureEdits({
		  success: function() {
		  	that.ld.division.set("fetched_edits", true);
		  	that.trigger("edits:ready");
		  },
		  error: function() {
		    errorHandler({
		    	button: that.ui.button
		    });
		  }
		});
	}

});
BFApp.Views.PublishEditsNotice = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/league/content/schedule/notices/publish_edits_notice",

	className: "schedule-navigation classic clearfix",

	ui: {
		"publishButton": "button[name='publish']",
		"discardButton": "button[name='discard']"
	},

	events: {
		"click button[name='publish']": "publishEdits",
		"click button[name='discard']": "discardEdits"
	},

	triggers: {
		"click a[name='back']": "reload:schedule"
	},

	initialize: function(options) {
		this.ld = options.ld;
	},

	publishEdits: function() {
		var that = this;
		disableButton(this.ui.publishButton);

		// ping server to publish edits
		$.ajax({
		  type: "post",
		  url: "/api/v1/divisions/" + this.ld.division.get("id") + "/publish_edits",
		  success: function() {
		  	that.trigger("reload:schedule");
		  },
		  error: function() {
		    errorHandler({
		      button: that.ui.publishButton
		    });
		  }
		});
	},

	discardEdits: function() {
		var that = this;
		disableButton(this.ui.discardButton);

		// ping server to publish edits
		$.ajax({
		  type: "post",
		  url: "/api/v1/divisions/" + this.ld.division.get("id") + "/clear_edits",
		  success: function() {
		  	that.trigger("reload:schedule");
		  },
		  error: function() {
		    errorHandler({
		      button: that.ui.discardButton
		    });
		  }
		});
	}

});
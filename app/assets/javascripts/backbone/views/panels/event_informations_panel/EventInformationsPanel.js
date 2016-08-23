BFApp.Views.EventInformationsPanel = Marionette.Layout.extend({

	template: "backbone/templates/panels/event_informations_panel/event_informations_panel",

	ui: {
		"datePicker": "#event-date"
	},

	initialize: function(options) {
		this.listenTo(this.model, "change", this.render);
	},

	serializeData: function() {
		var eventTime = this.model.getDateObj();
		var location = this.model.get("location");

		return {
			title: this.model.get("title"),
			locationTitle: (location) ? location.get("title") : null,
			locationQueryString: (location) ? location.getQueryString() : null,
			date: eventTime.getMediumDateTime()
		};
	}

});
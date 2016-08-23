BFApp.Views.UserScheduleEmpty = Marionette.ItemView.extend({

	template: "backbone/templates/common/content/empty_tab",

	serializeData: function() {
		var title, msg;
		if (this.options.isYourProfile) {
			title = "There are no events in your schedule";
			msg = "Schedule your next game or practice... Add an event below!";
		}
		else {
			title = "This user has no upcoming events";
			msg = "";
		}
		return {
			icon: "calendar",
			title: title,
			msg: msg
		};
	}

});
BFApp.Views.LeagueScheduleEmpty = Marionette.ItemView.extend({

	template: "backbone/templates/common/content/empty_tab",

	serializeData: function() {
		var title;
		if (this.options.showFutureFixtures) {
			title = "There are no upcoming games";
		} else {
			title = "There are no previous games";
		}

		return {
			icon: "calendar",
			title: title,
			msg: ""
		};
	}

});
BFApp.Views.PastGamesEmpty = Marionette.ItemView.extend({
	

	template: "backbone/templates/common/content/empty_tab",

	serializeData: function() {
		var title, msg;
		if (this.options.isYourProfile) {
			title = "You don't have any past games";
			msg = "Games will appear here after you've played them";
		}
		else {
			title = "This user has no past games";
			msg = "";
		}
		return {
			icon: "star",
			title: title,
			msg: msg
		};
	}

});
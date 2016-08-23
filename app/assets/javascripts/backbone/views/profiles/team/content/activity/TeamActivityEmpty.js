BFApp.Views.TeamActivityEmpty = Marionette.ItemView.extend({
	
	template: "backbone/templates/common/content/empty_tab",

	className: "main-content",

	serializeData: function() {
		var msg;
		
		if (ActiveApp.Permissions.get("canUpdateTeam")) {
			msg = "Get started: add games to the schedule and invite players";
		} else {
			msg = "";
		}

		return {
			icon: "star",
			title: "There has been no activity!",
			msg: msg
		};
	}

});
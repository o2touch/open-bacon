BFApp.Views.EventActivityEmpty = Marionette.ItemView.extend({
	
	template: "backbone/templates/common/content/empty_tab",

	serializeData: function() {
		var msg;

		if (BFApp.rootController.permissionsModel.can("canManageAvailability")) {
			msg = "Get started by inviting some players";
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
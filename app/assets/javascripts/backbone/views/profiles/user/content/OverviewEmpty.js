BFApp.Views.OverviewEmpty = Marionette.ItemView.extend({

	template: "backbone/templates/common/content/empty_tab",

	serializeData: function() {
		var title, msg, tenant = ActiveApp.Tenant.get("general_copy").app_name;
		if (this.options.isYourProfile) {
			title = "Hey! Welcome to " + tenant + ", this is your overview panel";
			msg = "Start by creating a team or schedule an event";
		} else {
			title = "This user has no activity to display";
			msg = "";
		}
		return {
			icon: "star",
			title: title,
			msg: msg
		};
	}

});
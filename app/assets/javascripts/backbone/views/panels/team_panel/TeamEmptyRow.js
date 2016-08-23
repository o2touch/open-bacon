BFApp.Views.TeamEmptyRow = Marionette.ItemView.extend({

	template: "backbone/templates/common/content/empty_panel",
	
	serializeData: function() {
		return {
			icon: "badge",
			title: "There are no teams",
			msg: ""
		};
	}

});




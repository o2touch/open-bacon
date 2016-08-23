BFApp.Views.DangerPanel = Marionette.ItemView.extend({

	template: "backbone/templates/panels/danger_panel",


	events:{
		"click .remove-event" : "removeEvent"
	},
		
	removeEvent: function() {
		var that = this;
		if (confirm("Are you sure that you want to remove this event?")) {
			var location = "/teams/" + ActiveApp.Event.get("team").get('id') + "#schedule";
			this.model.destroy({
				success: function(model, response) {
					window.location = location;
				}
			});
		}
		return false;
	},
	


});

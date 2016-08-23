BFApp.Views.TeamsheetList = Marionette.CompositeView.extend({

	template: "backbone/templates/panels/teamsheet_panel/teamsheet_list",

	ui: {
		"userListAvailable": ".users-list.available",
		"userListAwaiting": ".users-list.awaiting",
		"userListUnavailable": ".users-list.unavailable"
	},

	initialize: function(options) {
		this.listenTo(this.collection, "add remove change:response_status", this.render);
	},

	appendHtml: function(cv, iv, i) {
		var status = iv.model.get("response_status");
		if (status == 1) {
			this.ui.userListAvailable.find(".empty").remove();
			this.ui.userListAvailable.append(iv.el);
		} else if (status == 2) {
			this.ui.userListAwaiting.find(".empty").remove();
			this.ui.userListAwaiting.append(iv.el);
		} else if (status == 0) {
			this.ui.userListUnavailable.find(".empty").remove();
			this.ui.userListUnavailable.append(iv.el);
		}
	},

	serializeData: function() {
		return  {
			unavailable: this.collection.where({
				response_status: 0
			}).length,
			available: this.collection.where({
				response_status: 1
			}).length,
			awaiting: this.collection.where({
				response_status: 2
			}).length,
			copy: ActiveApp.Tenant.get("general_copy").availability
		}
	}

});
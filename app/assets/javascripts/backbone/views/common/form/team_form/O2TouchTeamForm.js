BFApp.Views.O2TouchTeamForm = BFApp.Views.TeamForm.extend({

	validateSave: function() {
		return this.model.validateSave(this.ui.teamName, null);
	},

	getCustomParams: function() {
		var params = {};
		if (this.options.type != "edit") {
			params.tenant_id = BFApp.constants.getTenantId("O2 Touch");
		}
		return params;
	}

});
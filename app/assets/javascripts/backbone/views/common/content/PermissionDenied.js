BFApp.Views.PermissionDenied = Marionette.ItemView.extend({

	template: "backbone/templates/common/content/permission_denied",

	serializeData: function() {
		return {
			msg: this.options.msg
		};
	}

});
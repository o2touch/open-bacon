BFApp.Views.UserRow = Marionette.ItemView.extend({

	tagName: "li",
	template: "backbone/templates/panels/users_list_panel/user_row",

	serializeData: function() {
		return {
			url: this.model.getHref(),
			htmlPic: this.model.getPictureHtml("thumb"),
			name: this.model.get("name")
		}
	},


});
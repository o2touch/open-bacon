BFApp.Views.SquadPlayerChildren = Marionette.Layout.extend({

	template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player_children",

	className: "player-children",

	events: {
		"click a[name='edit-user-child'].pen": "showChildForm",
		"click a[name='edit-user-child'].check": "saveChild",
		"submit form[name='child-name-form']": "saveChild"
	},

	serializeData: function() {
		return {
			children: this.options.children,
			isRegistered: this.model.isRegistered(),
			currentUserCanManageTeam: ActiveApp.Permissions.get("canManageTeam")
		};
	},

	showChildForm: function(e) {
		$(e.currentTarget).parents(".child").find("a[name='edit-user-child']").removeClass("pen").addClass("check");
		$(e.currentTarget).parents(".child").find("form[name='child-name-form']").removeClass("hide");
		return false;
	},

	hideChildForm: function(e) {
		$(e.currentTarget).parents(".child").find("a[name='edit-user-child']").removeClass("check").addClass("pen");
		$(e.currentTarget).parents(".child").find("form[name='child-name-form']").addClass("hide");
		return false;
	},

	saveChild: function(e) {
		var that = this;
		var childrenContainer = $(e.currentTarget).parents(".child");
		var name = childrenContainer.find("input[name='child-name-input']");
		var children = ActiveApp.Teammates.get("user" + childrenContainer.data("id"));

		var nameFormat = BFApp.validation.isName({
			htmlObject: name,
			alertBox: false
		});

		if (nameFormat) {
			if (children.get("name") == name.val()) {
				that.hideChildForm(e);
			} else {

				children.save({
					name: name.val()
				}, {
					success: function() {
						childrenContainer.find(".child-name").text(name.val());
						that.hideChildForm(e);
					},
					error: function() {
						errorHandler();
					}
				});
			}
		}
		return false;
	}


});
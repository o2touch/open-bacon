BFApp.Views.SquadPlayerProfile = Marionette.Layout.extend({
	template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player_profile",

	className: "player-profile",

	ui: {
		userName: ".user-name",
		userNameInput: "input[name='user-name-input']",
		userNameForm: "form[name='user-name-form']",
		userNameIcon: "a[name='edit-user-name']"
	},

	events: {
		"submit form[name='user-name-form']": "saveName",
		"click a[name='edit-user-name'].check": "saveName",
		"click a[name='edit-user-name'].pen": "toggleNameForm"
	},

	initialize: function() {
		this.NameFormVisible = false;
	},

	toggleNameForm: function() {
		if (!this.NameFormVisible) {
			this.ui.userNameIcon.removeClass("pen").addClass("check");
			this.ui.userNameForm.removeClass("hide");
			this.NameFormVisible = true;
		} else {
			this.ui.userNameIcon.removeClass("check").addClass("pen");
			this.ui.userNameForm.addClass("hide");
			this.NameFormVisible = false;
		}

		return false;
	},

	saveName: function() {
		var that = this;
		var nameFormat = BFApp.validation.isName({
			htmlObject: this.ui.userNameInput
		});

		if (nameFormat) {
			var name = this.ui.userNameInput.val();
			if (name == this.model.get("name")) {
				this.toggleNameForm();
			} else {
				this.model.save({
					name: name
				}, {
					success: function() {
						that.ui.userName.text(name);
						that.toggleNameForm();
					},
					error: function() {
						errorHandler();
					}
				});
			}
		}
		return false;
	},

	serializeData: function() {
		var parentSection = false;
		if (this.options.parentSection) {
			parentSection = true;
		}

		return {
			profile_pic: this.model.get("profile_picture_thumb_url"),
			name: this.model.get("name"),
			parentSection: parentSection,
			isRegistered: this.model.isRegistered(),
			currentUserCanManageTeam: ActiveApp.Permissions.get("canManageTeam"),
			isJunior: this.model.isJunior(),
			url: this.model.getHref()
		};
	}

});
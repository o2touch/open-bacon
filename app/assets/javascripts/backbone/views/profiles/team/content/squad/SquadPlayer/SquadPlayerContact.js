BFApp.Views.SquadPlayerContact = Marionette.Layout.extend({

	template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player_contact",
	className: "player-contact",

	ui: {
		userEmail: ".user-email",
		userEmailInput: "input[name='user-email-input']",
		userEmailForm: "form[name='user-email-form']",
		userEmailIcon: "a[name='edit-user-email']",
		userMobile: ".user-mobile",
		userMobileForm: "form[name='user-mobile-form']",
		userMobileIcon: "a[name='edit-user-mobile']"
	},

	events: {
		"submit form[name='user-email-form']": "saveEmail",
		"submit form[name='user-mobile-form']": "saveMobile",
		"click a[name='edit-user-email'].check": "saveEmail",
		"click a[name='edit-user-email'].pen": "toggleEmailForm",
		"click a[name='edit-user-mobile'].check": "saveMobile",
		"click a[name='edit-user-mobile'].pen": "toggleMobileForm",
		"click a[name='show-mobile-form']": "toggleMobileForm"
	},

	serializeData: function() {
		var parentSection = false;
		if (this.options.parentSection) {
			parentSection = true;
		}
		return {
			email: this.model.get("email"),
			mobileNumber: this.model.get("mobile_number"),
			isRegistered: this.model.isRegistered(),
			currentUserCanManageTeam: ActiveApp.Permissions.get("canManageTeam"),
			parentSection: parentSection,
			id: this.model.get("id"),
		};
	},

	initialize: function() {
		this.emailFormVisible = false;
		this.mobileFormVisible = false;
	},

	onShow: function() {
		this.$("#user-mobile-number").intlTelInput(getIntlTelInputOptions());
	},

	toggleEmailForm: function() {
		if (!this.emailFormVisible) {
			this.ui.userEmailIcon.removeClass("pen").addClass("check");
			this.ui.userEmailForm.removeClass("hide");
			this.emailFormVisible = true;
		} else {
			this.ui.userEmailIcon.removeClass("check").addClass("pen");
			this.ui.userEmailForm.addClass("hide");
			this.emailFormVisible = false;
		}

		return false;
	},


	toggleMobileForm: function() {
		if (!this.mobileFormVisible) {
			this.ui.userMobileIcon.removeClass("pen").addClass("check");
			this.ui.userMobileForm.removeClass("hide");
			this.mobileFormVisible = true;
		} else {
			this.ui.userMobileIcon.removeClass("check").addClass("pen");
			this.ui.userMobileForm.addClass("hide");
			this.mobileFormVisible = false;
		}

		return false;
	},

	saveMobile: function() {
		var that = this;

		var isMobile = BFApp.validation.isMobile({
			htmlObject: this.$("#user-mobile-number")
		});

		if (isMobile) {
			var mobile = this.$("#user-mobile-number").intlTelInput("getCleanNumber");

			if (mobile == this.model.get("mobile_number")) {
				this.toggleMobileForm();
			} else {
				this.model.save({
					mobile_number: mobile
				}, {
					success: function() {
						that.ui.userMobile.text(mobile);
						that.toggleMobileForm();
					},
					error: function() {
						errorHandler();
					}
				});
			}
		}
		return false;
	},

	saveEmail: function() {
		var that = this;
		var emailFormat = BFApp.validation.isEmail({
			htmlObject: this.ui.userEmailInput
		});

		if (emailFormat) {
			var email = this.ui.userEmailInput.val();
			if (email == this.model.get("email")) {
				this.toggleEmailForm();
			} else {
				this.model.save({
					email: email
				}, {
					success: function() {
						that.ui.userEmail.text(email);
						that.toggleEmailForm();
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
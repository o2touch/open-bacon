BFApp.Views.InvitePlayerPanel = Marionette.ItemView.extend({

	template: "backbone/templates/panels/invite_player_panel",

	tagName: "form",

	className: "classic invite-player-panel",

	teamsheet: null,

	events: {
		"click button[title='send invite']": "addNewPlayerStandard",
	},

	triggers: {
		"click .close-panel": "dismiss"
	},

	initialize: function(options) {
		if (options.teamsheet) {
			this.teamsheet = options.teamsheet;
		}
	},

	serializeData: function() {
		return {
			tenant: ActiveApp.Tenant.get("general_copy").app_name
		};
	},

	onShow: function() {
		this.$("#new-user-mobile-number").intlTelInput(getIntlTelInputOptions());
		this.$("input, textarea").placeholder();
	},

	validate: function() {
		var name = BFApp.validation.isName({
			htmlObject: this.$(".new-user-name")
		});
		var email = BFApp.validation.isEmail({
			htmlObject: this.$(".new-user-email")
		});
		var mobile = BFApp.validation.isMobile({
			htmlObject: this.$("#new-user-mobile-number")
		});

		return (name && email && mobile);
	},

	addNewPlayerStandard: function() {
		var that = this;
		var mobileInput = this.$("#new-user-mobile-number");

		if (this.teamsheet.filter(function(teamsheet_entry) {
			return teamsheet_entry.get('user').get('email') == that.$(".new-user-email").val().trim();
		}).length > 0) {
			alert("A user with this email address has been invited to this event.");
			return false;
		}

		if (this.validate()) {
			disableButton(this.$("button[title='send invite']"));

			var params = {
				name: this.$(".new-user-name").val().trim(),
				email: this.$(".new-user-email").val().trim(),
				mobile_number: mobileInput.intlTelInput("getCleanNumber")
			};

			var customParams = {
				save_type: "TEAMMEMBER",
				event_id: ActiveApp.Event.get('id')
			};

			if (ActiveApp.Event.get('team').get('id') !== undefined) {
				customParams.team_id = ActiveApp.Event.get('team').get('id');
			}

			var user = new App.Modelss.User();
			user.save(params, {
				success: function(model, response) {
					that.$(".new-user-name").val("");
					that.$(".new-user-email").val("");
					mobileInput.val("");
					that.$(".new-user-name").select();
					enableButton(that.$("button[title='send invite']"));
				},
				error: function(model, response) {
					errorHandler({
						button: that.$("button[title='send invite']")
					});
				},
				custom: customParams
			});
		}

		return false;
	},


});
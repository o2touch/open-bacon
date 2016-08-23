BFApp.Views.ResponsePanel = Marionette.ItemView.extend({

	template: "backbone/templates/panels/response_panel/response_panel",

	className: "availability",

	ui: {
		"AvailabilityStatus": ".availability-status",
		"AvailabilityForm": ".availability-choice"
	},

	events: {
		"click .availability-edit": "showForm",
		"click .available": "markAvailable",
		"click .unavailable": "markUnavailable"
	},

	showForm: function() {
		this.ui.AvailabilityStatus.addClass("hide");
		this.ui.AvailabilityForm.removeClass("hide");
		this.$el.removeClass("available unavailable");
		return false;
	},


	hideForm: function() {
		this.ui.AvailabilityStatus.removeClass("hide");
		this.ui.AvailabilityForm.addClass("hide");
		return false;
	},

	initialize: function() {
		this.listenTo(this.model, "change:response_status", this.render);
	},


	markUnavailable: function() {
		if (App.pageType == "open-invite") {
			this.trigger('button-unavailable:clicked');
		} else {
			if (this.model.get("response_status") !== 0) {
				this.model.markUnavailable();
			}
			this.$el.addClass("unavailable");
		}
		this.hideForm();

		return false;
	},

	markAvailable: function() {
		if (App.pageType == "open-invite") {
			this.trigger('button-available:clicked');
		} else {
			if (this.model.get("response_status") !== 1) {
				this.model.markAvailable();
			}
			this.$el.addClass("available");
		}
		this.hideForm();

		return false;
	},


	serializeData: function() {
		return {
			pic: this.model.get("user").get("profile_picture_thumb_url"),
			name: this.model.get("user").get("name"),
			status: this.model.get("response_status"),
			currentUser: (this.model.get("user").get("id") == ActiveApp.CurrentUser.get("id")),
			copy: ActiveApp.Tenant.get("general_copy").availability
		}
	},

	onRender: function() {
		this.$el.removeClass("unavailable available awaiting");
		if (this.model.get("response_status") == 0) {
			this.$el.addClass("unavailable");
		} else if (this.model.get("response_status") == 1) {
			this.$el.addClass("available");
		} else {
			this.$el.addClass("awaiting");
		}
	},


});
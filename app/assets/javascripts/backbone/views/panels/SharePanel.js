BFApp.Views.SharePanel = Marionette.ItemView.extend({

	template: "backbone/templates/panels/share_panel",

	initialize: function() {
		this.openInviteLink = "http://" + window.location.host + "/g/" + this.model.get("open_invite_link");
		this.eventDate = this.model.getMyLocalisedDateObj().format("L");
	},

	events: {
		"click .btn-twitter": "twitter",
		"click .btn-facebook": "facebook",
		"click .btn-email": "email",
	},

	facebook: function() {
		void(window.open('http://www.facebook.com/share.php?u='.concat(encodeURIComponent(this.openInviteLink))));
		return false;
	},

	twitter: function() {
		void(window.open('http://twitter.com/home/?status='.concat('I just set up a game on ').concat(this.eventDate).concat(', go to ').concat(encodeURIComponent(this.openInviteLink).concat(' to RSVP!'))));
		return false;
	},

	email: function() {
		void(window.open('mailto:?body=Follow the link to RSVP: '.concat(this.openInviteLink).concat('&subject=New game on ').concat(this.eventDate)));
		return false;
	},


});
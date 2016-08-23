BFApp.Views.AddPlayersNotice = Marionette.ItemView.extend({

	template: "backbone/templates/event/add_players_notice",

	className: "team-onboarding-godbar columns nine centered",

	initialize: function() {
		// we use this to know when it's safe to close the godbar region
		this.isAddPlayersNotice = true;
	},

	onRender: function() {
		this.$el.css({"opacity": "0"});
		this.$el.animate({opacity: 1,}, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
	}

});

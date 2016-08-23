BFApp.Views.TeamCardView = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/team/content/team_card",

	ui: {
		"followButton": "button[name='follow']"
	},

	triggers: {
		"click button[name='follow']": "clicked:follow",
		"click button[name='unfollow']": "clicked:unfollow"
	},

	// events: {
	// 	"mouseover button[name='unfollow']": "toggleButtonState",
	// 	"mouseout button[name='unfollow']": "toggleButtonState"
	// },
	// 
	// toggleButtonState: function(e) {
	// 	var button = $(e.currentTarget);
	// 	button.toggleClass("alert");
	// 	button.text((button.hasClass("alert")) ? "Unfollow" : "Following");
	// },

	serializeData: function() {
		var sportSlug = convertToSlug(this.model.get("sport"));
		var league = this.model.get("league");

		return {
			leagueModel: (this.model.get("league")) ? this.model.get("league") : null,
			division: (this.model.get("division")) ? this.model.get("division") : null,
			leagueName: this.model.get("league_name"),
			name: this.model.get("name"),
			htmlPic: this.model.getPictureHtml("medium"),
			sport: this.model.get("sport"),
			showMeta: this.options.showMeta,
			events: ActiveApp.ProfileTeamStats.numTeamEvents,
			teammates: ActiveApp.ProfileTeamStats.numTeamPlayers,
			sportIcon: _.contains(BFApp.constants.sportsIcons, sportSlug) ? sportSlug : "badge",
			canFollow: (ActiveApp.pageType == "public-team"),
			isFollowing: (ActiveApp.CurrentUser && ActiveApp.CurrentUser.isFollower(ActiveApp.ProfileTeam))
		};
	}

});
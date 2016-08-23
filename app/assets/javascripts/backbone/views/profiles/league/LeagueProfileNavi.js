BFApp.Views.LeagueProfileNavi = Marionette.ItemView.extend({

	className: "content-navi",

	tagName: "ul",

	template: "backbone/templates/profiles/league/navi",

	ui: {
		"scheduleLink": "a[name='schedule']",
		"resultsLink": "a[name='results']",
		"messageLink": "a[name='message']",
		"teamsLink": "a[name='teams']",
		"membersLink": "a[name='members']"
	},

	initialize: function(options) {
		this.ld = options.ld;
		var that = this;
		this.rootPath = ActiveApp.ProfileLeague.getHref();
		BFApp.LeagueProfile.router.bind('route', function(route) {
			that.onNavigationChange(route);
		});
	},

	serializeData: function() {
		return {
			showMessageTab: this.options.showMessageTab,
			showTeamsTab: this.options.showTeamsTab,
			showMembersTab: this.options.showMembersTab
		}
	},

	// we must update the links whenever the division changes etc
	updateLinks: function() {
		var root;
		if (this.ld.division) {
			root = this.rootPath + "/divisions/" + this.ld.division.get("id");
		} else {
			root = this.rootPath;
		}
		this.ui.scheduleLink.attr("href", root + "/schedule");
		this.ui.resultsLink.attr("href", root + "/results");
		this.ui.messageLink.attr("href", root + "/message");
		this.ui.teamsLink.attr("href", root + "/teams");
		this.ui.membersLink.attr("href", root + "/members");
	},

	// update the selected tab
	onNavigationChange: function(route) {

		var tab = route.replace('show', '').toLowerCase();
		var navEl = this.$el.find("a[name=" + tab + "]").parent("li");

		if (!navEl.hasClass('selected')) {
			this.$el.find('li.selected').removeClass('selected');
			navEl.addClass('selected');
		}
	}

});
BFApp.Views.TeamProfileNavi = Marionette.ItemView.extend({

	className: "content-navi",
	tagName:"ul",
	template: "backbone/templates/profiles/team/navi",
	
	initialize: function(){
		var that = this;
		//console.log("BFApp.Views.TeamProfileNavi %o", BFApp.TeamProfile.router);
		BFApp.TeamProfile.router.bind('route', function(route) {
			that.onNavigationChange(route);
		});
	},
	
	// update the selected tab
	onNavigationChange: function(route){
		//console.log("TeamProfileNavi::onNavigationChange, route="+route);
		
		// don't bother changing the selected tab as the hash will get updated anyway
		if (route == "defaultRoute") return;

		var tab = route.replace('show', '').toLowerCase();
		var navEl = this.$el.find("#nav-" + tab);

		if (navEl.hasClass('selected')) {
			return;
		}
		else {
			this.$el.find('li.selected').removeClass('selected');
			navEl.addClass('selected');
		}
	},

	serializeData: function() {
		return {
			canViewActivity: ActiveApp.Permissions.get("canViewProfileFeed"),
			canSeeTeamTab: ActiveApp.Permissions.get("canViewPrivateDetails")
		};
	}

});
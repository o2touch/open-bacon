BFApp.Views.SquadPlayerPermission = Marionette.Layout.extend({
	template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player_permission",
	
	events: {
		"click .organiser-toggle": "toggleOrganiserPermissions"
	},
	
	className: "player-permissions",
	
	serializeData: function() {
		return {
			isOrganiser: this.model.isTeamOrganiser(ActiveApp.ProfileTeam)
		};
	},
	
	toggleOrganiserPermissions: function() {
		var isOrganiser = this.model.isTeamOrganiser(ActiveApp.ProfileTeam);
		var isRegistered = this.model.isRegistered();
		var that = this;
		this.$(".organiser-toggle").prop("disabled", true);
		if (isRegistered && !isOrganiser) {
	
			var params = {
				team_id: ActiveApp.ProfileTeam.get("id"),
				user_id: this.model.get("id"),
				role_id: 2
			};
			teamRole = new App.Modelss.TeamRole();
			teamRole.save(params, {
				success: function() {
					that.model.get("team_roles").add(teamRole);
					that.trigger("permissions:changes");
					that.$(".organiser-toggle").prop("disabled", false);
	
				},
				error: function() {
					errorHandler();
					that.$(".organiser-toggle").prop("disabled", false);
				}
			});
	
		} else if (isRegistered && isOrganiser) {
			var teamRole = this.model.getTeamRole(ActiveApp.ProfileTeam, 2);
			teamRole.destroy({
				success: function() {
					that.trigger("permissions:changes");
					that.$(".organiser-toggle").prop("disabled", false);
				},
				error: function() {
					errorHandler();
					that.model.get("team_roles").add(teamRole);
					that.$(".organiser-toggle").prop("disabled", false);
				}
			});
		}
	}
	
});
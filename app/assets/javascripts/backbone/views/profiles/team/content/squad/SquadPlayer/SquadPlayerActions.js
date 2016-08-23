BFApp.Views.SquadPlayerActions = Marionette.Layout.extend({
	template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player_actions",
	
	className : "player-actions",
	
	events: {
		"click a[title='delete player']": "removePlayer"
	},
	
	serializeData: function() {
		var isParent = this.model.isParent();
		var childrens = false;
		
		if (isParent) {
			childrens = this.model.getChildrens(ActiveApp.Teammates);
		}
		
		return {
			isParent: isParent,
			childrens: childrens
		};
  },
	
	removeParents:function(){
		/* 
			This bit about junior can be quite complicated to understand.
			To be simple, when removing a junior, we want to remove the 
			parent(s) as well, but only if this (those) parent got only
			this child in the team.
			
			1. Get the parents of the junior
			2. Iterate threw those parent
				for each parent, get the children in team
				If only one child in team, then remove the parent
		*/
		var that = this;
		
		/* Get his parents */
		var parents = this.model.getParents(ActiveApp.Teammates);
		
		/* For each parent */
		_.each(parents.models, function(parent){
		
			/* Get single parent childrens total in team */
			var parentChildren = parent.getChildrens(ActiveApp.Teammates);
			
			/* if have only one child (current model) */
			if(parentChildren.length == 1){
					
				/* Destroy that mofo */
				var parentTeamRoles = parent.getTeamRole(ActiveApp.ProfileTeam, 3);
				parentTeamRoles.destroy({
					success: function() {
						ActiveApp.Teammates.remove(parent);
						that.trigger("remove:player");
					},
					error: function() {
						errorHandler();
					}
				});
			}
		});
		
	},
	
	removePlayer: function() {
		var that = this;
		if (confirm("Are you sure that you want to remove this player from this team?")) {
		
			/* Get proper team role (player or parent) */
			var teamrole;
			if (this.model.isTeamParent(ActiveApp.ProfileTeam)) {
				teamrole = this.model.getTeamRole(ActiveApp.ProfileTeam, 3);
			} else {
				teamrole = this.model.getTeamRole(ActiveApp.ProfileTeam, 1);
			}
			
			/* Remove his team role*/
			teamrole.destroy({
				success: function() {},
				error: function() {
					errorHandler();
				}
			});
		
			/* And his parent*/
			if (this.model.isJunior()) {
				this.removeParents();
			}
			
			/* Remove that mofo from the team */
			ActiveApp.Teammates.remove(that.model);
			that.trigger("remove:player");
			
		}
		return false;
	}
	
});
BFApp.Views.SquadPlayerParents = Marionette.Layout.extend({
	template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player_parents",
	
	className: "player-parent",
	
	regions:{
		head: "#r-parent-profile",
		contact: "#r-parent-contact"
	},
	
	onRender:function(){
		/* parent header */
		var parentProfile = new BFApp.Views.SquadPlayerProfile({
			model:this.model,
			parentSection:true
		});
		this.head.show(parentProfile);
		
		/* parent contact */
		var parentContact = new BFApp.Views.SquadPlayerContact({
			model:this.model,
			parentSection:true
		});
		this.contact.show(parentContact);
	}
	
});
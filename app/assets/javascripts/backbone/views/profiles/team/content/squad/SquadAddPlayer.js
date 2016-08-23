BFApp.Views.SquadAddPlayer = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_add_players",

  className: "squad-sidebar-section",

  serializeData: function() {
  	return {
  		disable: ActiveApp.Teammates.hasDemoPlayers()
  	}
  }
  
});

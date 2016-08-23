SFApp.Views.SignupFlowConfirmation = Marionette.ItemView.extend({

	template: "backbone/templates/signup_flow/confirmation",
	
	onRender: function() {
		this.$(".bf-icon").hide();
		this.$(".create-team-spinner").spin({
			width: 6,
			radius: 30,
			corners: 1,
			color: '#333',
			top: 'auto',          
			left: 'auto', 
		});

		// jump straight to your new team page
		window.location = "/teams/"+this.options.team_id+"#schedule";
	}

});
SFApp.Views.SignupFlowFacebook = Marionette.ItemView.extend({

	template: "backbone/templates/signup_flow/facebook",

	initialize: function(options) {
		$.ajax({
			type : "post",
			url : "/api/v1/users/new_team_organiser?team_uuid="+options.team_uuid,
			success : function(data) {
				window.location.hash = "#confirmation";
			},
			error: function(data) {
				errorHandler();
			}
		});
	}

});
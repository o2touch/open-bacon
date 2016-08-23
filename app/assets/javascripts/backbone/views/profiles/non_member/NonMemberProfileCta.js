BFApp.Views.NonMemberProfileCtaSignup = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/non_member/non_member_profile_cta_signup",
	
	events: {
		"click .login-link": "showLogin"
	},
	
	showLogin: function(){
		BFApp.vent.trigger("login-popup:show");
	},
	
	serializeData:function(){
		return {
			who:this.options.who,
			context:this.options.context
		};
	}

});

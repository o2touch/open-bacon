BFApp.Views.NonMemberProfileLayout = Marionette.Layout.extend({

	className: "team-page-private row",
	
	template: "backbone/templates/profiles/non_member/non_member_layout",

	regions: {
		card: "#r-card",
		content: "#r-content",
		form: "#r-form"
	},
	
	serializeData:function(){
		return {
			columns: this.options.columns
		};
	}

});

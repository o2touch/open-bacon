BFApp.Views.LeagueScheduleHelpText = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/league/widget/league_schedule_help_text",

	className: "edit-onboarding clearfix",

	triggers: {
	  "click button[name='add']": "add:fixture"
	},
	
	
});
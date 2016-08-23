BFApp.Views.EditScheduleHelpText = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/team/widget/edit_schedule_help_text",

	className: "edit-onboarding clearfix",

	triggers: {
	  "click .schedule-add-event": "add:event"
	}
	
});
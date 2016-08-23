BFApp.Views.ScheduleLayout = Marionette.Layout.extend({

	className: "main-content main-content-schedule",
	template: "backbone/templates/common/content/schedule/schedule_layout",

	regions: {
		empty: "#schedule-empty",
		eventForm: "#schedule-event-form",
		loading: "#schedule-loading",
		thisWeek: "#schedule-this-week",
		nextWeek: "#schedule-next-week",
		afterNextWeek: "#schedule-after-next-week"
	}

});
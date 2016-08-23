/**
 * Event row for Next/Last game widget
 */
BFApp.Views.GameActivityRow = Marionette.ItemView.extend({

	template: "backbone/templates/panels/game_activity_panel/game_activity_row",

	initialize: function() {
		this.listenTo(this.model, "change", this.render);
	},

	serializeData: function() {
		var eventModel = this.model;

		//score for game
		var scoreFor = null;
		var scoreAgainst = null;
		if (eventModel.get("score_for")) {
			scoreFor = eventModel.get("score_for");
			scoreAgainst = eventModel.get("score_against");
		}

		var event_time = eventModel.getDateObj();
		var location = (eventModel.get("location")) ? eventModel.get("location").get("title") : "";

		//event information
		var eventType = eventModel.get("game_type_string");
		if (eventType === "event") eventType = "other";
		var eventRealType = eventModel.get("game_type");

		return {
			rowTitle: this.options.title,
			title: eventModel.get("title"),
			time: event_time.getFormattedTime(),
			date: event_time.date(),
			cutMonth: event_time.format("MMM"),
			timeTBC: this.model.get("time_tbc"),
			eventType: eventType,
			location: location,
			href: eventModel.getHref(),
			scoreFor: scoreFor,
			scoreAgainst: scoreAgainst,
			eventRealType: eventRealType,
			gameStatus: eventModel.get("status")
		};
	}

});
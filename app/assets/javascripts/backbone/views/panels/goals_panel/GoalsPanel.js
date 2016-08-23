BFApp.Views.GoalsPanel = Marionette.Layout.extend({

	template: "backbone/templates/panels/goals_panel/goals_panel",

	className: "panel goals",

	regions: {
		"progress": "#r-goals-progress",
		"goals": "#r-goals-list"
	},

	events: {
		"click .goal-row.incomplete": "goalClicked"
	},

	initialize: function(options) {
		this.collection = options.collection;

		// merge data from server with our hardcoded values
		this.collection.set([{
			listPosition: 0,
			key: "register",
			complete: true,
			percentProgress: 45,
			title: "Sign up",
			description: "Create your team"
		}, {
			listPosition: 1,
			key: "team_created_one_event",
			percentProgress: 15,
			title: "Add an Event",
			description: "Add one to your schedule",
			teamAction: "addEvent"
		}, {
			listPosition: 2,
			key: "team_enroled_four_players",
			percentProgress: 20,
			subGoal: 4,
			title: "Add your Players",
			description: "Add your team members",
			teamAction: "addPlayer"
		}, {
			listPosition: 3,
			key: "organiser_completed_event_page",
			percentProgress: 10,
			title: "Check out an Event Page",
			description: "Take a spin around a game/event page",
			teamAction: "viewSchedule"
		}, {
			listPosition: 4,
			key: "team_added_schedule",
			percentProgress: 10,
			subGoal: 4,
			title: "Add events to the Schedule",
			description: "Add the next 4 upcoming events",
			teamAction: "addEvent"
		}]);

		// init sub-goals
		var playersGoal = this.collection.get("team_enroled_four_players");
		var numPlayers;
		if (ActiveApp.Teammates.hasDemoPlayers()) {
			numPlayers = 0;
		} else {
			numPlayers = ActiveApp.Teammates.getNumPlayersExcludingMe(ActiveApp.ProfileTeam);
		}
		playersGoal.set("subGoalProgress", numPlayers);

		var eventsGoal = this.collection.get("team_added_schedule");
		var numEvents = ActiveApp.Events.length + ActiveApp.PastEvents.length;
		eventsGoal.set("subGoalProgress", numEvents);

		// event listener
		this.listenTo(this.collection, "change", this.render);
	},

	onRender: function() {
		var percentProgress = this.collection.getPercentProgress();

		// only display widget if progress<100% or they have the session variable
		if (percentProgress < 100 || $.cookie("showGoalsWidget")) {
			this.$el.removeClass("hide");
			var progressView = new BFApp.Views.GoalProgress({
				percentProgress: percentProgress
			});
			this.progress.show(progressView);

			if (percentProgress < 100) {
				var goalsList = new BFApp.Views.GoalsList({
					collection: this.collection
				});
				this.goals.show(goalsList);

				// once the percent has dipped below 100% we set the session var again
				$.cookie("showGoalsWidget", "true");
			} else {
				var completeMsgView = new BFApp.Views.GoalsCompleteMsg();
				this.goals.show(completeMsgView);
			}
		} else {
			this.$el.addClass("hide");
		}
	},

	goalClicked: function(e) {
		var stateAction = $(e.currentTarget).data("action");
		this.trigger("goal:clicked", stateAction);
	}

});
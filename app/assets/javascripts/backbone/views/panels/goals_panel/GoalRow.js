BFApp.Views.GoalRow = Marionette.ItemView.extend({

	template: "backbone/templates/panels/goals_panel/goal_row",

	tagName: "li",

	initialize: function() {
		// save the goal action on the element to use later, when it is clicked
		this.$el.data("action", this.model.get("teamAction"));
	},

	serializeData: function() {
		var subGoal = this.model.get("subGoal");
		var subGoalProgress = this.model.get("subGoalProgress");
		if (subGoalProgress > subGoal) {
			subGoalProgress = subGoal;
		}
		var complete = this.model.get("complete");
		return {
			title: this.model.get("title"),
			description: this.model.get("description"),
			complete: complete,
			subGoal: subGoal,
			subGoalProgress: subGoalProgress,
			showSubGoalProgress: (subGoal && subGoalProgress && !complete)
		};
	},

	onRender: function() {
		var completeStr = (this.model.get("complete")) ? 'complete' : 'incomplete';
		this.$el.addClass("goal-row " + completeStr);
	}

});
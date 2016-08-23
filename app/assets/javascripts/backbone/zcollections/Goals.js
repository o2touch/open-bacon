App.Collections.Goals = Backbone.LiveCollection.extend({

	model: App.Modelss.Goal,

	comparator: function(model) {
		return model.get("listPosition");
	},

	getPercentProgress: function() {
		var percent = 0;
		_.each(this.models, function(goal) {
			if (goal.get("complete")) {
				percent += goal.get("percentProgress");
			}
		});
		return percent;
	}

});
App.Collections.Fixtures = Backbone.Collection.extend({

	model: App.Modelss.Fixture,

	initialize: function(models, options) {
		var ascending = (options && options.ascendingOrder) ? true : false;
		this.comparator = function(model) {
			var millis = model.getMyLocalisedDateObj().valueOf();
			return (ascending) ? millis : -millis;
		};
	},

	getFixtures: function(getFutureFixtures) {
		return _.filter(this.models, function(model) {
			var isInFuture = model.isInFuture();
			return (getFutureFixtures) ? isInFuture : !isInFuture;
		});
	}

});
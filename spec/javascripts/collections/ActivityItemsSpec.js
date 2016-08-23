describe("App.Collections.ActivityItems", function() {

	beforeEach(function() {
		this.activityItems = new App.Collections.ActivityItems();
	});

	it("sorts collection conditionally by starred_at and then created_at", function() {
		// we're not testing the set function here, so reset it to the default
		this.activityItems.set = Backbone.Collection.prototype.set;

		// NOTE: unstarred items are actually newer (earlier created_at)
		// date variance happens by years

		// most recent starred item
		var starred1 = new Backbone.Model({
			created_at: "2002-01-01T12:00:00Z",
			starred_at: "2001-01-01T12:00:00Z"
		});
		// the ai collection comparator uses the ai model's isStarred method
		// which we fake here, for each model
		starred1.isStarred = function() {return true;};
		// second most recent starred item
		var starred2 = new Backbone.Model({
			created_at: "2001-01-01T12:00:00Z",
			starred_at: "2000-01-01T12:00:00Z"
		});
		starred2.isStarred = function() {return true;};
		// most recent unstarred item
		var unstarred1 = new Backbone.Model({
			created_at: "2004-01-01T12:00:00Z"
		});
		unstarred1.isStarred = function() {return false;};
		// second most recent unstarred item
		var unstarred2 = new Backbone.Model({
			created_at: "2003-01-01T12:00:00Z"
		});
		unstarred2.isStarred = function() {return false;};

		// added in random order
		this.activityItems.add([starred2, unstarred1, starred1, unstarred2]);

		expect(this.activityItems.at(0)).toBe(starred1);
		expect(this.activityItems.at(1)).toBe(starred2);
		expect(this.activityItems.at(2)).toBe(unstarred1);
		expect(this.activityItems.at(3)).toBe(unstarred2);
	});

});
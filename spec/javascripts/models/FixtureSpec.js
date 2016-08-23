describe("App.Modelss.Fixture", function() {

	var fixture;

	beforeEach(function() {
		fixture = new App.Modelss.Fixture();
	});

	afterEach(function() {
		fixture.destroy();
	});

	describe("making requests", function() {

		var fakeId = 123;

		// set these each time and test them
		var url, type;

		beforeEach(function() {
			spyOn($, "ajax");
		});

		afterEach(function() {
			var request = $.ajax.mostRecentCall.args[0];
			expect(request.type).toEqual(type);
			expect(request.url).toEqual(url);
		});

		// create
		it("can create a new fixture", function() {
			var divisionId = 678;
			fixture.save({}, {
				divisionId: divisionId
			});
			type = "POST";
			url = "/api/v1/divisions/"+divisionId+"/fixtures";
		});

		// update
		it("can update an existing fixture", function() {
			fixture.set({
				id: fakeId
			});
			// calling save on a model that already has an id will trigger an update
			fixture.save();
			type = "PUT";
			url = "/api/v1/fixtures/" + fakeId;
		});

	});



	describe("making changes", function() {

		var oldTitle = "Old Title", newTitle = "New Title";
		var location;

		beforeEach(function() {
			location = new App.Modelss.Location({
				title: oldTitle
			});
			fixture.set({
				title: oldTitle,
				location: location
			});
			fixture.store();
		});

		afterEach(function() {
			location.destroy();
		});

		it("can detect changes on a model", function() {
			expect(fixture.hasChanges()).toEqual(false);
			fixture.set("title", newTitle);
			expect(fixture.hasChanges()).toEqual(true);
		});

		it("can detect changes on a related model", function() {
			expect(fixture.hasChanges()).toEqual(false);
			fixture.get("location").set("title", newTitle);
			expect(fixture.hasChanges()).toEqual(true);
		});

		it("can revert changes on a model", function() {
			fixture.set("title", newTitle);
			fixture.get("location").set("title", newTitle);
			fixture.restore();
			expect(fixture.get("title")).toEqual(oldTitle);
			expect(fixture.get("location").get("title")).toEqual(oldTitle);
		});

	});

});
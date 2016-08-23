describe("App.Collections.Fixtures", function() {

	var fixtures;

	afterEach(function() {
		fixtures = null;
	});

	describe("sorting", function() {

		var fixture1, fixture2, fixture3;

		beforeEach(function() {
			// NOTE: date variance done in years
			fixture1 = new App.Modelss.Fixture({
				time: "2001-01-01T12:00:00Z"
			});
			fixture2 = new App.Modelss.Fixture({
				time: "2002-01-01T12:00:00Z"
			});
			fixture3 = new App.Modelss.Fixture({
				time: "2003-01-01T12:00:00Z"
			});
		});

		afterEach(function() {
			fixture1.destroy();
			fixture2.destroy();
			fixture3.destroy();
		});

		it("can sort in ascending order", function() {
			var options = {
				ascendingOrder: true
			};
			fixtures = new App.Collections.Fixtures([fixture3, fixture1, fixture2], options);

			expect(fixtures.at(0)).toBe(fixture1);
			expect(fixtures.at(1)).toBe(fixture2);
			expect(fixtures.at(2)).toBe(fixture3);
		});

		it("can sort in descending order", function() {
			var options = {
				ascendingOrder: false
			};
			fixtures = new App.Collections.Fixtures([fixture3, fixture1, fixture2], options);

			expect(fixtures.at(0)).toBe(fixture3);
			expect(fixtures.at(1)).toBe(fixture2);
			expect(fixtures.at(2)).toBe(fixture1);
		});

	});



	describe("filtering", function() {

		var futureFixture, pastFixture;

		beforeEach(function() {
			var year = moment().year();
			futureFixture = new App.Modelss.Fixture({
				time: (year + 1) + "-01-01T12:00:00Z"
			});
			pastFixture = new App.Modelss.Fixture({
				time: (year - 1) + "-01-01T12:00:00Z"
			});
			fixtures = new App.Collections.Fixtures([futureFixture, pastFixture]);
		});

		afterEach(function() {
			futureFixture.destroy();
			pastFixture.destroy();
		});

		it("can get only future fixtures", function() {
			var futureFixtures = fixtures.getFixtures(true);
			expect(fixtures.length).toEqual(2);
			expect(futureFixtures.length).toEqual(1);
			expect(futureFixtures[0]).toBe(futureFixture);
		});

		it("can get only past fixtures", function() {
			var pastFixtures = fixtures.getFixtures(false);
			expect(fixtures.length).toEqual(2);
			expect(pastFixtures.length).toEqual(1);
			expect(pastFixtures[0]).toBe(pastFixture);
		});

	});

});
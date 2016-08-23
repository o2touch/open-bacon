describe("App.Modelss.Event", function() {

	var eventModel;

	beforeEach(function() {
		eventModel = new App.Modelss.Event();
	});


	describe("isInFuture", function() {

		it("past event", function() {
			var year = moment().year() - 1;
			eventModel.set("time", year + "-01-01T01:00:00Z");
			expect(eventModel.isInFuture()).toEqual(false);
		});

		it("future event", function() {
			var year = moment().year() + 1;
			eventModel.set("time", year + "-01-01T01:00:00Z");
			expect(eventModel.isInFuture()).toEqual(true);
		});

	});


	describe("getting date objects", function() {

		// manually build an ISO date string for testing
		var year = 2014,
			month = 3,
			monthString = "03",
			day = 15,
			dayString = "15",
			hours = 12,
			minutes = 30,
			seconds = 25,
			isoDateString = year + "-" + monthString + "-" + dayString + "T" + hours + ":" + minutes + ":" + seconds + "Z";

		it("getDateObj", function() {
			// getDateObj uses event.get(time_local)
			eventModel.set("time_local", isoDateString);
			var date = eventModel.getDateObj();
			expect(date.year()).toEqual(year);
			expect(date.month()).toEqual(month - 1);
			expect(date.date()).toEqual(day);
			expect(date.hours()).toEqual(hours);
			expect(date.minutes()).toEqual(minutes);
			expect(date.seconds()).toEqual(seconds);
		});

		it("getMyLocalisedDateObj", function() {
			// getMyLocalisedDateObj uses event.get(time)
			eventModel.set("time", isoDateString);
			var date = eventModel.getMyLocalisedDateObj();
			expect(date.year()).toEqual(year);
			expect(date.month()).toEqual(month - 1);
			expect(date.date()).toEqual(day);
			// the only difference: when localised, the time is adjusted to the timezone of
			// the user's browser, which currently is PST e.g. UTC-8
			var offset = getTimezoneHours();
			expect(date.hours()).toEqual(hours - offset);
			expect(date.minutes()).toEqual(minutes);
			expect(date.seconds()).toEqual(seconds);
		});

	});


	describe("lastReminderOldEnough", function() {

		it("last reminder was just now", function() {
			var date = moment.utc().toCustomISO();
			eventModel.set("time_of_last_reminder", date);
			expect(eventModel.lastReminderOldEnough()).toEqual(false);
		});

		it("last reminder was 2 hours ago", function() {
			var date = moment.utc().subtract("hours", 2).toCustomISO();
			eventModel.set("time_of_last_reminder", date);
			expect(eventModel.lastReminderOldEnough()).toEqual(true);
		});

	});

});
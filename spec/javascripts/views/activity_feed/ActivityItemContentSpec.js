describe("Activity Item Content Views", function() {

	var user, model, view;

	beforeEach(function() {
		user = new App.Modelss.User({
			name: "Jack"
		});
	});

	function getView(viewClass, context) {
		var aiView = new viewClass({
			model: model,
			context: context
		});
		aiView.render();
		return aiView;
	}


	describe("obj is event", function() {

		var event;

		beforeEach(function() {
			event = new App.Modelss.Event({
				title: "Party",
				team: new Backbone.Model()
			});
			model = new App.Modelss.ActivityItem({
				subj: user,
				obj: event
			});
		});

		describe("BFApp.Views.EventActivatedActivityItem", function() {

			it("EVENT PAGE: can see the users name and NOT the event title", function() {
				view = getView(BFApp.Views.EventActivatedActivityItem, "event");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).not.toContainText(event.get("title"));
			});

			it("TEAM PAGE: can see the users name and the event title", function() {
				view = getView(BFApp.Views.EventActivatedActivityItem, "team");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).toContainText(event.get("title"));
			});

			it("USER PAGE: can see the users name and the event title", function() {
				view = getView(BFApp.Views.EventActivatedActivityItem, "user");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).toContainText(event.get("title"));
			});

		});


		describe("BFApp.Views.EventCancelledActivityItem", function() {

			it("EVENT PAGE: can see the users name and NOT the event title", function() {
				view = getView(BFApp.Views.EventCancelledActivityItem, "event");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).not.toContainText(event.get("title"));
			});

			it("TEAM PAGE: can see the users name and the event title", function() {
				view = getView(BFApp.Views.EventCancelledActivityItem, "team");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).toContainText(event.get("title"));
			});

			it("USER PAGE: can see the users name and the event title", function() {
				view = getView(BFApp.Views.EventCancelledActivityItem, "user");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).toContainText(event.get("title"));
			});

		});


		describe("BFApp.Views.EventCreatedActivityItem", function() {

			beforeEach(function() {
				event.set("game_type_string", "game");
				window.ActiveApp = {};
			});

			it("EVENT PAGE: can see the users name and NOT the event game_type_string", function() {
				view = getView(BFApp.Views.EventCreatedActivityItem, "event");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).not.toContainText(event.get("game_type_string"));
			});

			it("TEAM PAGE: can see the users name and the event game_type_string", function() {
				view = getView(BFApp.Views.EventCreatedActivityItem, "team");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).toContainText(event.get("game_type_string"));
			});

			it("USER PAGE: can see the users name and the event game_type_string", function() {
				view = getView(BFApp.Views.EventCreatedActivityItem, "user");
				expect(view.$el).toContainText(user.get("name"));
				expect(view.$el).toContainText(event.get("game_type_string"));
			});

		});

	});


	describe("BFApp.Views.EventResultActivityItem", function() {

		var scoreFor = 1,
			scoreAgainst = 2;

		beforeEach(function() {
			event = new App.Modelss.Event({
				title: "Party"
			});
			model = new App.Modelss.ActivityItem({
				meta_data: '{"score_for": ["", "' + scoreFor + '"], "score_against": ["", "' + scoreAgainst + '"]}',
				subj: user,
				obj: {
					obj_type: "EventResult",
					event: event
				}
			});
		});

		it("EVENT PAGE: can see the users name, NOT the event title and the score", function() {
			view = getView(BFApp.Views.EventResultActivityItem, "event");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).not.toContainText(event.get("title"));
			expect(view.$el).toContainText(scoreFor + " - " + scoreAgainst);
		});

		it("TEAM PAGE: can see the users name, the event title and the score", function() {
			view = getView(BFApp.Views.EventResultActivityItem, "team");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
			expect(view.$el).toContainText(scoreFor + " - " + scoreAgainst);
		});

		it("USER PAGE: can see the users name, the event title and the score", function() {
			view = getView(BFApp.Views.EventResultActivityItem, "user");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
			expect(view.$el).toContainText(scoreFor + " - " + scoreAgainst);
		});

	});


	describe("BFApp.Views.InviteReminderActivityItem", function() {

		beforeEach(function() {
			event = new App.Modelss.Event({
				title: "Party"
			});
			model = new App.Modelss.ActivityItem({
				subj: user,
				obj: {
					obj_type: "InviteReminder",
					teamsheet_entry: {
						event: event
					}
				}
			});
		});

		it("EVENT PAGE: can see the users name and NOT the event title", function() {
			view = getView(BFApp.Views.InviteReminderActivityItem, "event");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).not.toContainText(event.get("title"));
		});

		it("TEAM PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.InviteReminderActivityItem, "team");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
		});

		it("USER PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.InviteReminderActivityItem, "user");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
		});

	});


	describe("BFApp.Views.InviteResponseActivityItem", function() {

		beforeEach(function() {
			event = new App.Modelss.Event({
				title: "Party"
			});
			model = new App.Modelss.ActivityItem({
				subj: user,
				obj: {
					obj_type: "InviteResponse",
					response_status: 1,
					teamsheet_entry: {
						event: event
					}
				}
			});
		});

		it("EVENT PAGE: can see the users name and NOT the event title", function() {
			view = getView(BFApp.Views.InviteResponseActivityItem, "event");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).not.toContainText(event.get("title"));
		});

		it("TEAM PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.InviteResponseActivityItem, "team");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
		});

		it("USER PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.InviteResponseActivityItem, "user");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
		});

	});


	describe("BFApp.Views.TeamsheetActivityItem", function() {

		beforeEach(function() {
			event = new App.Modelss.Event({
				title: "Party"
			});
			model = new App.Modelss.ActivityItem({
				subj: user,
				obj: {
					obj_type: "TeamsheetEntry",
					event: event
				}
			});
		});

		it("EVENT PAGE: can see the users name and NOT the event title", function() {
			view = getView(BFApp.Views.TeamsheetActivityItem, "event");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).not.toContainText(event.get("title"));
		});

		it("TEAM PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.TeamsheetActivityItem, "team");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
		});

		it("USER PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.TeamsheetActivityItem, "user");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(event.get("title"));
		});

	});


	describe("BFApp.Views.MessageActivityItem", function() {

		var eventTitle = "Party";

		beforeEach(function() {
			model = new App.Modelss.ActivityItem({
				subj: user,
				obj: {
					obj_type: "EventMessage",
					messageable_id: 1,
					messageable_type: "Event",
					messageable: {
						title: eventTitle
					}
				}
			});
		});

		it("EVENT PAGE: can see the users name and NOT the event title", function() {
			view = getView(BFApp.Views.MessageActivityItem, "event");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).not.toContainText(eventTitle);
		});

		it("TEAM PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.MessageActivityItem, "team");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(eventTitle);
		});

		it("USER PAGE: can see the users name and the event title", function() {
			view = getView(BFApp.Views.MessageActivityItem, "user");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(eventTitle);
		});

	});


	describe("BFApp.Views.EventUpdatedActivityItem", function() {

		var updatedAttr = "title",
			oldAttr = "Old Title",
			newAttr = "New Title";

		beforeEach(function() {
			event = new App.Modelss.Event({
				title: "Party"
			});
			model = new App.Modelss.ActivityItem({
				meta_data: '{"' + updatedAttr + '": ["' + oldAttr + '", "' + newAttr + '"]}',
				subj: user,
				obj: event
			});
		});

		it("EVENT PAGE: can see the users name, the new value for the updated attrbute and NOT the event title", function() {
			view = getView(BFApp.Views.EventUpdatedActivityItem, "event");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el.find(".activity-comment-update")).toContainText(newAttr);
			expect(view.$el).not.toContainText(event.get("title"));
		});

		it("TEAM PAGE: can see the users name, the updated attrbute and the event title", function() {
			view = getView(BFApp.Views.EventUpdatedActivityItem, "team");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(updatedAttr);
			expect(view.$el).toContainText(event.get("title"));
		});

		it("USER PAGE: can see the users name, the updated attrbute and the event title", function() {
			view = getView(BFApp.Views.EventUpdatedActivityItem, "user");
			expect(view.$el).toContainText(user.get("name"));
			expect(view.$el).toContainText(updatedAttr);
			expect(view.$el).toContainText(event.get("title"));
		});

	});

});
describe("BFApp.Views.ActivityMessageWidget", function() {

	/* Spy globals */
	var view, button;
	var toggleStarSpy;
	var clickGroupsButtonSpy;
	var selectUsersGroupsSpy;
	var addMessageSpy;
	var updateButtonStateSpy;
	var validateSpy;
	var messageWidgetView;

	/* 
	Spy are define before the view on the view.prototype because it wasn't working
	with sinon.spy on the previous test (the detective team J&L are working on it)
	(http://stackoverflow.com/questions/8441612/why-is-this-sinon-spy-not-being-called-when-i-run-this-test) 
	*/

	beforeEach(function() {
		/* globals that are used inside the views */
		window.ActiveApp = {
			CurrentUser: new App.Modelss.User(),
			Event: new App.Modelss.Event(),
			ProfileTeam: new App.Modelss.Team(),
			ProfileDivision: new App.Modelss.Division(),
			Tenant: new Backbone.Model({
				general_copy: {
					availability: {}
				}
			})
		};
		window.analytics = {
			identify: function() {},
			track: function() {}
		};

		toggleStarSpy = sinon.spy(BFApp.Views.ActivityMessageWidget.prototype, 'toggleStar');
		clickGroupsButtonSpy = sinon.spy(BFApp.Views.ActivityMessageWidget.prototype, 'clickGroupsButton');
		selectUsersGroupsSpy = sinon.spy(BFApp.Views.ActivityMessageWidget.prototype, 'selectUsersGroup');
		addMessageSpy = sinon.spy(BFApp.Views.ActivityMessageWidget.prototype, 'addMessage');
		updateButtonStateSpy = sinon.spy(BFApp.Views.ActivityMessageWidget.prototype, 'updateButtonState');
		validateSpy = sinon.spy(BFApp.Views.ActivityMessageWidget.prototype, 'validate');
	});

	afterEach(function() {
		delete ActiveApp;
		delete analytics;
		toggleStarSpy.restore();
		clickGroupsButtonSpy.restore();
		selectUsersGroupsSpy.restore();
		addMessageSpy.restore();
		updateButtonStateSpy.restore();
		validateSpy.restore();
	});



	/* General view behavior (team/event page & user/organiser) */
	describe("General behavior", function() {

		beforeEach(function() {
			view = new BFApp.Views.ActivityMessageWidget({
				context: "event",
				isOrganiser: true
			});
			view.render();
			button = view.$el.find("button[title='add message']");
		});

		it("Can't submit if message is empty", function() {
			expect(button).toBeDisabled();
		});

		it("Don't save if the message is too long", function() {
			var ajaxSpy = spyOn($, "ajax");

			// quick way to get string length ~ 5000 (max is currently 4000)
			var x = "1234567890";
			for (var i = 0; i < 6; i++) {
				x += x.concat(x);
			}

			view.$el.find(".message-area").text(x).keyup();
			button.click();

			expect(validateSpy).toHaveBeenCalled();
			expect(validateSpy.lastCall.returnValue).toEqual(false);
			expect(ajaxSpy).not.toHaveBeenCalled();
		});

		it("trigger a save if there's content", function() {
			spyOn($, "ajax");

			var msgText = 'some content';
			view.$el.find(".message-area").text(msgText).keyup();
			expect(updateButtonStateSpy).toHaveBeenCalled();

			button.click();
			expect(addMessageSpy).toHaveBeenCalled();
			expect(validateSpy).toHaveBeenCalled();
			expect(validateSpy.lastCall.returnValue).toEqual(true);

			var request = $.ajax.mostRecentCall.args[0];
			var data = JSON.parse(request.data);
			expect(request.type).toEqual("POST");
			expect(request.url).toEqual("/api/v1/messages");
			expect(data.message.text).toEqual(msgText);
		});

	});



	/* Event page test */
	describe("on event page", function() {

		/* Organiser on event page test */
		describe("as an organizer", function() {

			beforeEach(function() {
				view = new BFApp.Views.ActivityMessageWidget({
					context: "event",
					isOrganiser: true
				});
				view.render();
				button = view.$el.find("button[title='add message']");
			});

			it("has control (dropdown/star)", function() {
				expect(view.$el.find(".highlight-star")).toHaveLength(1);
				expect(view.$el.find(".show-groups-dropdown")).toHaveLength(1);
				expect(view.$el.find(".groups-dropdown")).toHaveLength(1);
			});

			describe("submitting a new message", function() {

				var starred, groups;

				beforeEach(function() {
					spyOn($, "ajax");
				});

				afterEach(function() {
					// add msg text and submit
					view.$el.find(".message-area").text('some content').keyup();
					button.click();

					// check ajax call
					var request = $.ajax.mostRecentCall.args[0];
					var data = JSON.parse(request.data);
					expect(data.message.recipients.groups).toEqual(groups);
					if (starred) {
						expect(data.message.starred).toEqual(starred);
					} else {
						expect(data.message.starred).toBeUndefined();
					}
				});

				it("can star a message", function() {
					view.$el.find(".star").click();
					expect(view.$el.find(".star")).toHaveClass("selected");
					expect(toggleStarSpy).toHaveBeenCalledOnce();

					// expected ajax values
					starred = true;
					// default groups is group IDs 1 and 2
					groups = ["1", "2"];
				});

				it("can open dropdown and select group", function() {
					expect(view.$el.find(".groups-dropdown")).toHaveClass("hide");

					view.$el.find(".show-groups-dropdown").click();
					expect(view.$el.find(".groups-dropdown")).not.toHaveClass("hide");
					expect(clickGroupsButtonSpy).toHaveBeenCalled();

					view.$el.find(".group-of-players").first().trigger('click');
					expect(selectUsersGroupsSpy).toHaveBeenCalledOnce();

					// expected ajax values
					starred = false;
					groups = ["2"];
				});



			});

			it("does the correct request", function() {
				spyOn($, "ajax");
				var msgText = 'some content';
				view.$el.find(".message-area").text(msgText).keyup();
				button.click();

				var request = $.ajax.mostRecentCall.args[0];
				var data = JSON.parse(request.data);
				expect(request.type).toEqual("POST");
				expect(request.url).toEqual("/api/v1/messages");
				expect(data.message.text).toEqual(msgText);

				expect(data.message.role_id).toEqual(2);
				expect(data.message.role_type).toEqual("Team");

			});

		});

		/* Player on event page test */
		describe("as a player", function() {

			beforeEach(function() {
				view = new BFApp.Views.ActivityMessageWidget({
					context: "event",
					isOrganiser: false
				});
				view.render();
				button = view.$el.find("button[title='add message']");
			});

			it("has no controls (dropdown/hightlight) on event page", function() {

				expect(view.$el.find(".highlight-star")).toHaveLength(0);
				expect(view.$el.find(".msg-groups")).toHaveClass("hide");

			});

			it("does the correct request", function() {
				spyOn($, "ajax");

				var msgText = 'some content';
				view.$el.find(".message-area").text(msgText).keyup();
				button.click();

				var request = $.ajax.mostRecentCall.args[0];
				var data = JSON.parse(request.data);
				expect(request.type).toEqual("POST");
				expect(request.url).toEqual("/api/v1/messages");
				expect(data.message.text).toEqual(msgText);

				expect(data.message.role_id).toEqual(1);
				expect(data.message.role_type).toEqual("Team");

			});

		});

	});

	/* Player on team page test */
	describe("on team page", function() {

		/* Organiser on team page test */
		describe("as an organizer", function() {

			beforeEach(function() {
				view = new BFApp.Views.ActivityMessageWidget({
					context: "team",
					isOrganiser: true
				});
				view.render();
				button = view.$el.find("button[title='add message']");
			});

			it("has control star but not dropdown", function() {
				expect(view.$el.find(".highlight-star")).toHaveLength(1);
				expect(view.$el.find(".show-groups-dropdown")).toHaveLength(0);
				expect(view.$el.find(".groups-dropdown")).toHaveLength(0);
			});

			it("does the correct request", function() {
				spyOn($, "ajax");

				var msgText = 'some content';
				view.$el.find(".message-area").text(msgText).keyup();
				button.click();

				var request = $.ajax.mostRecentCall.args[0];
				var data = JSON.parse(request.data);
				expect(request.type).toEqual("POST");
				expect(request.url).toEqual("/api/v1/messages");
				expect(data.message.text).toEqual(msgText);

				expect(data.message.role_id).toEqual(2);
				expect(data.message.role_type).toEqual("Team");

			});

		});


		/* Organiser on team page test */
		describe("as an player", function() {

			beforeEach(function() {
				view = new BFApp.Views.ActivityMessageWidget({
					context: "team",
					isOrganiser: false
				});
				view.render();
				button = view.$el.find("button[title='add message']");
			});

			it("does the correct request", function() {
				spyOn($, "ajax");

				var msgText = 'some content';
				view.$el.find(".message-area").text(msgText).keyup();
				button.click();

				var request = $.ajax.mostRecentCall.args[0];
				var data = JSON.parse(request.data);
				expect(request.type).toEqual("POST");
				expect(request.url).toEqual("/api/v1/messages");
				expect(data.message.text).toEqual(msgText);

				expect(data.message.role_id).toEqual(1);
				expect(data.message.role_type).toEqual("Team");

			});

		});

	});

	/* Player on team page test */
	describe("on league page", function() {

		/* Organiser on team page test */
		describe("as an league organizer", function() {

			beforeEach(function() {
				view = new BFApp.Views.ActivityMessageWidget({
					context: "league",
					isOrganiser: true
				});
				view.render();
				button = view.$el.find("button[title='add message']");
			});

			it("does the correct request", function() {
				spyOn($, "ajax");

				var msgText = 'some content';
				view.$el.find(".message-area").text(msgText).keyup();
				button.click();

				var request = $.ajax.mostRecentCall.args[0];
				var data = JSON.parse(request.data);
				expect(request.type).toEqual("POST");
				expect(request.url).toEqual("/api/v1/messages");
				expect(data.message.text).toEqual(msgText);

				expect(data.message.role_id).toEqual(1);
				expect(data.message.role_type).toEqual("League");

			});

		});
	});

});
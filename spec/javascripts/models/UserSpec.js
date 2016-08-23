describe("App.Modelss.User", function() {

	var user;

	beforeEach(function() {
		user = new App.Modelss.User();
	});

	afterEach(function() {
		user.destroy();
	});

	describe("sync URLs", function() {

		var fakeId = 123;
		var fakeRelationalId = "user" + fakeId;

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

		/**
		 * Basic CRUD operations
		 *
		 * I don't think we actually do a pure CREATE, READ or DELETE operation anywhere,
		 * but good to keep these tested
		 */

		// create
		it("creating a new user", function() {
			user.save();
			type = "POST";
			url = "/api/v1/users/registrations?";
		});

		// read
		it("reading an existing user", function() {
			// set the regular ID field as well as the relationId field
			// to replicate a real situation
			user.set({
				id: fakeId,
				relationalId: fakeRelationalId
			});
			user.fetch();
			url = "/api/v1/users/" + fakeId;
			type = "GET";
		});

		// update e.g. edit profile on user page
		it("updating an existing user", function() {
			user.set({
				id: fakeId,
				relationalId: fakeRelationalId
			});
			// calling save on a model that already has an id will trigger an update
			user.save();
			type = "PUT";
			url = "/api/v1/users/" + fakeId;
		});

		// delete
		it("deleting an existing user", function() {
			user.set({
				id: fakeId,
				relationalId: fakeRelationalId
			});
			user.destroy();
			type = "DELETE";
			url = "/api/v1/users/" + fakeId;
		});



		/**
		 * Non-basic CRUD operations
		 */


		/* Site organisers/admins creating users through invites etc */

		// team email invite (add to teammates)
		it("creating a new player from a team email invite", function() {
			var saveType = "TEAMPROFILE";
			var teamId = 456;
			var options = {
				custom: {
					save_type: saveType,
					team_id: teamId
				}
			};
			user.save({}, options);
			type = "POST";
			url = "/api/v1/users/invitations?save_type=" + saveType + "&team_id=" + teamId;
		});

		// junior team email invite (add to teammates)
		it("creating a new player from a junior team email invite", function() {
			var saveType = "JUNIOR";
			var teamId = 456;
			var options = {
				custom: {
					save_type: saveType,
					team_id: teamId
				}
			};
			user.save({}, options);
			type = "POST";
			url = "/api/v1/users/invitations?save_type=" + saveType + "&team_id=" + teamId;
		});

		// event email invite (add to teamsheet)
		it("creating a new player from an event email invite", function() {
			var saveType = "TEAMMEMBER";
			var teamId = 456;
			var options = {
				custom: {
					save_type: saveType,
					team_id: teamId
				}
			};
			user.save({}, options);
			type = "POST";
			url = "/api/v1/users/invitations?save_type=" + saveType + "&team_id=" + teamId;
		});


		/* Users triggering registrations themselves */

		// signup flow
		it("creating a new organiser from the signup flow", function() {
			var saveType = "SIGNUPFLOW";
			var teamUuid = 456;
			var options = {
				custom: {
					save_type: saveType,
					team_uuid: teamUuid
				}
			};
			user.save({}, options);
			type = "POST";
			url = "/api/v1/users/registrations?team_uuid=" + teamUuid + "&save_type=" + saveType;
		});

		// team open invite
		it("creating a new user from a team open invite", function() {
			var saveType = "TEAMOPENINVITELINK";
			var teamId = 789;
			var token = "abc123";
			var options = {
				custom: {
					save_type: saveType,
					team_id: teamId,
					token: token
				}
			};
			user.save({}, options);
			type = "POST";
			url = "/api/v1/users/registrations?save_type=" + saveType + "&team_id=" + teamId + "&token=" + token;
		});

		// event open invite
		it("creating a new user from an event open invite", function() {
			var saveType = "OPENINVITE";
			var eventId = 789;
			var responseStatus = 1;
			var options = {
				custom: {
					save_type: saveType,
					event_id: eventId,
					response_status: responseStatus
				}
			};
			user.save({}, options);
			type = "POST";
			url = "/api/v1/users/registrations?save_type=" + saveType + "&event_id=" + eventId + "&response_status=" + responseStatus;
		});


		/* Confirming invited users (already exist in DB) */

		// e.g. from team invite, event invite, junior invite etc
		it("confirming an invited user", function() {
			user.set({
				id: fakeId,
				relationalId: fakeRelationalId
			});
			var saveType = "CONFIRM_USER";
			var options = {
				custom: {
					save_type: saveType
				}
			};
			user.save({}, options);
			type = "PUT";
			url = "/api/v1/users/registrations?save_type=" + saveType;
		});

	});

});
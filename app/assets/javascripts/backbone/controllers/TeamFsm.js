BFApp.Controllers.TeamFsm = Marionette.Controller.extend({

	initialize: function() {

		this.stateValues = {
			"addFirstEvent": {
				template: "add_first_event",
				teamAction: "addEvent"
			},
			"addPlayers": {
				template: "add_players",
				teamAction: "addPlayer"
			},
			"addRealPlayers": {
				template: "add_real_players",
				teamAction: "addPlayer"
			},
			"checkoutEventPage": {
				template: "checkout_event_page"
			},
			"addSchedule": {
				template: "add_schedule",
				teamAction: "addEvent"
			},
			"done": {
				template: "done"
			}
		};

		// State enum. Structure: num Events, num Real/Demo players, Event Page Unfinished/Finished
		// Note: 1e means 1-3 events, and 4e means 4+ events
		// Note: 1d means 1+ demo players (we dont care how many they have, just that they have at least 1)
		// Note: all states (even 0e0rEpf) are possible as you can do shit then delete events and players
		this.states = {

			/*************************
			 * EVENT PAGE UNFINISHED
			 *************************/
			// 0 real players
			"0e0rEpu": this.stateValues["addFirstEvent"],
			"1e0rEpu": this.stateValues["addPlayers"],
			"4e0rEpu": this.stateValues["addPlayers"],
			// 1+ demo players
			"0e1dEpu": this.stateValues["addFirstEvent"],
			"1e1dEpu": this.stateValues["checkoutEventPage"],
			"4e1dEpu": this.stateValues["checkoutEventPage"],
			// 1-3 real players
			"0e1rEpu": this.stateValues["addFirstEvent"],
			"1e1rEpu": this.stateValues["checkoutEventPage"],
			"4e1rEpu": this.stateValues["checkoutEventPage"],
			// 4+ real players
			"0e4rEpu": this.stateValues["addFirstEvent"],
			"1e4rEpu": this.stateValues["checkoutEventPage"],
			"4e4rEpu": this.stateValues["checkoutEventPage"],

			/***********************
			 * EVENT PAGE FINISHED
			 ***********************/
			// 0 real players
			"0e0rEpf": this.stateValues["addFirstEvent"],
			"1e0rEpf": this.stateValues["addPlayers"], // Changed this from addRealPlayers
			"4e0rEpf": this.stateValues["addPlayers"], // Changed this from addRealPlayers
			// 1+ demo players
			"0e1dEpf": this.stateValues["addFirstEvent"],
			"1e1dEpf": this.stateValues["addRealPlayers"],
			"4e1dEpf": this.stateValues["addRealPlayers"],
			// 1-3 real players
			"0e1rEpf": this.stateValues["addFirstEvent"],
			"1e1rEpf": this.stateValues["addPlayers"], // Changed this from addRealPlayers
			"4e1rEpf": this.stateValues["addPlayers"], // Changed this from addRealPlayers
			// 4+ real players
			"0e4rEpf": this.stateValues["addFirstEvent"],
			"1e4rEpf": this.stateValues["addSchedule"],
			"4e4rEpf": this.stateValues["done"]
		};

		// initialise this.currentState
		this.updateState();
	},

	getStateTemplate: function() {
		var tplName = this.states[this.currentState].template;
		return "backbone/templates/profiles/team/content/fsm/" + tplName;
	},

	getStateAction: function() {
		return this.states[this.currentState].teamAction;
	},

	isComplete: function() {
		return (this.currentState == "4e4rEpf");
	},

	hasStateChange: function() {
		var prevState = this.currentState;
		this.updateState();
		return (this.currentState != prevState);
	},

	updateState: function(team) {
		// use ActiveApp.Teammates, ActiveApp.Events and the session bool for "completed event page"
		var numPlayers = ActiveApp.Teammates.getNumPlayersExcludingMe(ActiveApp.ProfileTeam);
		var hasDemoPlayers = ActiveApp.Teammates.hasDemoPlayers();
		if (hasDemoPlayers) {
			// if they have demo players, it doesn't matter how many
			numPlayers = "1";
		} else {
			// numPlayers can either be 0, 1 or 4
			if (numPlayers > 0 && numPlayers < BFApp.numTeammatesForActivation) {
				numPlayers = "1";
			} else if (numPlayers >= BFApp.numTeammatesForActivation) {
				numPlayers = "4";
			}
		}
		var playerType = (hasDemoPlayers) ? "d" : "r";

		var numEvents = ActiveApp.Events.length + ActiveApp.PastEvents.length;
		if (numEvents > 0 && numEvents < BFApp.numEventsForActivation) {
			numEvents = "1";
		} else if (numEvents >= BFApp.numEventsForActivation) {
			numEvents = "4";
		}

		var eventPageCondition = ActiveApp.Goals.get("organiser_completed_event_page").get("complete");
		var eventPageCode = (eventPageCondition) ? "Epf" : "Epu";

		this.currentState = numEvents + "e" + numPlayers + playerType + eventPageCode;
		//console.log("state="+this.currentState);
	}

});
BFApp.Views.TeamsheetPanel = Marionette.Layout.extend({

	template: "backbone/templates/panels/teamsheet_panel/teamsheet_panel",

	regions: {
		invitePlayer: ".invite-player-container",
		teamsheetRegion: ".teamsheet-container"
	},

	events: {
		"click .invite-player-button": "showInvitePopover"
	},

	serializeData: function() {
		return {
			canAddPlayer: (BFApp.rootController.permissionsModel.can("canManageAvailability") && !this.options.eventModel.isJuniorEvent() && this.options.eventModel.isOpen()),
		}
	},

	onRender: function() {

		var that = this;
		if (BFApp.rootController.permissionsModel.can("canManageAvailability") && !this.options.eventModel.isJuniorEvent() && this.options.eventModel.isOpen()) {

			var invitePlayerContentView = new BFApp.Views.InvitePlayerPanel({
				teamsheet: that.options.teamsheetCollection,
			});

			this.invitePlayerPanelView = new BFApp.Views.PanelLayout({
				panelIcon: "plus",
				panelTitle: "Invite player",
				panelTips: {
					text: "Get a fast response. Add their mobile number to send a text!",
					link: {
						url: "http://j.mp/14tTxSa",
						short: "Find out what we do?"
					}
				},
				extendClass: "invite-player hide popover"
			});
			this.invitePlayer.show(this.invitePlayerPanelView);
			this.invitePlayerPanelView.showContent(invitePlayerContentView);
			invitePlayerContentView.on("dismiss", function() {
				that.hideInvitePopover();
			})
		}

		var teamsheetListView = new BFApp.Views.TeamsheetList({
			collection: that.options.teamsheetCollection,
			itemView: BFApp.Views.TeamsheetRow
		});

		this.teamsheetRegion.show(teamsheetListView);


	},


	showInvitePopover: function() {
		this.invitePlayerPanelView.$el.removeClass("hide");
	},

	hideInvitePopover: function() {
		this.invitePlayerPanelView.$el.addClass("hide");
	}

});
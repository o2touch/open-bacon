BFApp.Views.NonMemberProfileInviteConfirmation = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/non_member/non_member_profile_invite_confirmation",

	events:{
		"click button[name='join-team']":"joinTeam"
	},

	joinTeam:function(){
		if (ActiveApp.CurrentUser.hasRoleInTeam(ActiveApp.ProfileTeam)) {
			window.location.reload();
		}
		//console.log("Join team")

		var tokenString = getParameterByName("token");
		var params = {
			team_id: ActiveApp.ProfileTeam.get('id'),
			token: tokenString,
			save_type: "TEAMOPENINVITELINK"
		};

		var user = ActiveApp.CurrentUser;
		user.save({}, {
			success: function() {
				BFApp.vent.trigger("team-open-invite-link-confirmation-popup:show", ActiveApp.ProfileTeam.get('name'));
			},
			error: function() {
				window.location.reload();
			},
			custom: params
		});

		return false;
	},

	serializeData:function(){
		return {
			who: this.options.who
		}
	}


});



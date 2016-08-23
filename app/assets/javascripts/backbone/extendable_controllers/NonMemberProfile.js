BFApp.Controllers.NonMemberProfile = Marionette.Controller.extend({

	initialize: function() {
		this.teamOil = (getParameterByName("token") !== "");
	},

	/* Display layout (with 1 or 2 columns) */
	showLayout: function(columns) {
		this.layout = new BFApp.Views.NonMemberProfileLayout({
			columns: columns
		});

		BFApp.content.show(this.layout);


	},

	/* Show login form */
	showLogin: function(redirect) {
		var that = this;
		var loginView = new BFApp.Views.LoginForm({
			className: "classic popover"
		});
		this.layout.form.show(loginView);

		loginView.on("signup:clicked", function() {
			if (redirect) {
				window.location.href = "/signup";
			} else {
				that.showTeamSignup();
			}
		});

		loginView.on("login:success", function() {
			if (this.teamOil) {
				BFApp.vent.trigger("team-open-invite-link-confirmation-popup:show", ActiveApp.ProfileTeam.get('name'));
			}
		});
	},

	/* Logged in user invite confirmation */
	showInvite: function() {
		var inviteConfirmation = new BFApp.Views.NonMemberProfileInviteConfirmation({
			className: "classic popover private-cta",
			who: ActiveApp.ProfileTeam.get("name")
		});
		this.layout.form.show(inviteConfirmation);
	},

	/* Show signup form */
	showTeamSignup: function(context) {
		var that = this;

		var signupOptions = {
			team_id: ActiveApp.ProfileTeam.get('id')
		};

		var title;
		if (context == "team-oil") {
			title = "Join " + ActiveApp.ProfileTeam.get("name") + " on Mitoo!";
			signupOptions.save_type = "TEAMOPENINVITELINK";
			signupOptions.token = getParameterByName("token");
		} else {
			title = "Sign-up to Mitoo &amp Follow " + ActiveApp.ProfileTeam.get("name");
			signupOptions.save_type = "TEAMFOLLOW";
		}

		var signupView = new BFApp.Views.SignupForm({
			className: "classic popover",
			model: ActiveApp.CurrentUser,
			signupOptions: signupOptions,
			title: title
		});

		signupView.on("login:clicked", function() {
			that.showLogin(false);
		});

		this.layout.form.show(signupView);
	},

	/* Show team card */
	showTeamCard: function() {
		var teamCardView = new BFApp.Views.TeamCardView({
			model: ActiveApp.ProfileTeam,
			showMeta: true,
			className: (ActiveApp.CurrentUser.isLoggedIn() && !this.teamOil) ? "six columns centered" : "eleven columns centered"
		});
		this.layout.card.show(teamCardView);
		return teamCardView;
	}

});
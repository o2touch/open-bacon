BFApp.Views.EventRegisterForm = BFApp.Views.O2TouchRegisterForm.extend({

  customSerializeData: function(data) {
    var entity = (ActiveApp.Event) ? "Event" : "Team";
    data.title = "Register to Join " + entity;
    data.msg = "Enter your details below to register for this " + entity.toLowerCase() + ".";
  },

  saveUser: function(e) {
    e.preventDefault();
    var that = this;

    if (this.validateForm()) {
      disableButton(this.ui.submitButton);

      var options = {
        success: function() {
          that.saveUserSuccess();
        },
        error: function(model, response, options) {
          errorHandler({
            type: "register",
            response: response,
            button: that.ui.submitButton
          });
        }
      };

      if (!this.isLoggedIn && ActiveApp.Event) {
        options.custom = {
          save_type: "EVENT",
          eventId: ActiveApp.Event.get("id")
        };
      }

      // use the model's setDOB() for consistency in formatting
      var dob = this.ui.dateInput.val();
      this.model.setDOB(dob);

      this.model.save(this.getAttributes(), options);
    }
  },

  saveUserSuccess: function() {
    var that = this,
    // if not event page, must be team page
      team = (ActiveApp.Event) ? ActiveApp.Event.get("team") : ActiveApp.ProfileTeam;

    // if the user is already logged in, we have only updated their model attributes
    // we now need to add the team role
    // UPDATE: but not if they already already have the team role (e.g. they were invited)
    if (this.isLoggedIn && !ActiveApp.CurrentUser.hasTeamRole(team, BFApp.constants.teamRole.PLAYER)) {
      var teamRole = new App.Modelss.TeamRole();
      teamRole.save({
        user_id: this.model.get("id"),
        team_id: team.get("id"),
        role_id: BFApp.constants.teamRole.PLAYER
      }, {
        success: function() {
          that.done();
        },
        error: function() {
          errorHandler({
            button: that.ui.submitButton
          });
        }
      });
    } else {
      this.done();
    }
  },

  done: function() {
    this.trigger("next");
  }

});
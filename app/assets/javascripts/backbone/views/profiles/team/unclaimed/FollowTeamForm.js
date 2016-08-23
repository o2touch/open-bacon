BFApp.Views.FollowTeamForm = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/unclaimed/follow_team_form",

  className: "follow-team-form",

  tagName: "form",

  events: {
    "click button[name='facebook']": "facebookLogin"
  },

  ui: {
    teamInput: "select[name='team']",
    nameInput: "input[name='name']",
    emailInput: "input[name='email']",
    passwordInput: "input[name='password']",
    submitButton: "button[type='submit']",
    facebookButton: "button[name='facebook']"
  },

  initialize: function(options) {
    this.team = options.team; // this wont exist on division/club pages
    this.division = options.division; // this wont exist on non-league team pages
    this.isLoggedIn = ActiveApp.CurrentUser.isLoggedIn();
    this.customInitialize(options);
  },

  customInitialize: function(options) {
    // override
  },

  onRender: function() {
    var that = this;
    this.$el.submit(function(e) {
      e.preventDefault();
      that.clickedFollow();
    });

    // if no teams, disable all the inputs
    if (this.emptyTeams) {
      this.$el.find("select,input,button").attr("disabled", true);
    }

    this.customOnRender();
  },

  customOnRender: function() {
    // override
  },

  serializeData: function() {
    var showTeamDropdown = (this.options.isDivision || this.options.isClub);
    var addButtonSuffix = (this.options.abTest == "club_follow_button_copy" && this.options.abTestB);

    var data = {
      isFollowing: this.options.isFollowing,
      isLoggedIn: this.isLoggedIn,
      showTeamDropdown: showTeamDropdown,
      buttonSuffix: (addButtonSuffix) ? " Now" : "",
      isExitPopup: this.options.isExitPopup
    };

    // division page
    if (showTeamDropdown) {
      data.teams = this.division.get("teams");
    }

    // use this in onRender
    this.emptyTeams = data.emptyTeams = (showTeamDropdown && !data.teams.length);

    this.customSerializeData(data);

    return data;
  },

  customSerializeData: function(data) {
    // override
  },

  validateForm: function() {
    var isValidEmail = BFApp.validation.isEmail({
      htmlObject: this.ui.emailInput
    });

    var isValidName = BFApp.validation.isName({
      htmlObject: this.ui.nameInput
    });

    var isValidPassword = BFApp.validation.isPassword({
      htmlObject: this.ui.passwordInput
    });

    return (isValidName && isValidEmail && isValidPassword);
  },

  // update button to say "Following"
  disableFollowButton: function(button) {
    button.prop("disabled", true);
    button.find(".spinner").remove();
    button.text("Following");
    button.removeClass("orange").addClass("grey");
  },

  disableAllButtons: function() {
    this.disableFollowButton($("button.follow-team")); // form button
    this.disableFollowButton($("button.follow-form")); // page buttons (open popup)
    this.disableFollowButton($("button[name='facebook']")); // facebook button
    // and all follow form inputs
    $("form.follow-team-form").find("input select").prop("disabled", true);
  },

  clickedFollow: function() {
    var userData;
    // either you're logged in, or you have valid data, or ignore
    if (this.isLoggedIn) {
      userData = {};
    } else if (this.validateForm()) {
      userData = this.getUserData();
    } else {
      return;
    }

    disableButton(this.ui.submitButton);
    this.sendQuery(this.ui.submitButton, userData, "Email");

    this.followAnalytics("Email");
  },

  getUserData: function() {
    return {
      name: this.ui.nameInput.val().trim(),
      email: this.ui.emailInput.val().trim(),
      password: this.ui.passwordInput.val()
    };
  },

  followAnalytics: function(type) {
    // override
  },

  sendQuery: function(button, userData, type) {
    var that = this;

    // if there is a team select box, then use that val
    var teamId = (this.ui.teamInput.length) ? this.ui.teamInput.val() : this.team.get("id");
    var teamName = (this.ui.teamInput.length) ? this.ui.teamInput.find("option:selected").text() :
      this.team.get("name");

    var options = {
      success: function(model) {

        // if they signed up with facebook, update the CurrentUser
        if (userData.facebook_token) {
          ActiveApp.CurrentUser.set(model);
        }

        // first update buttons etc
        if (that.options.isClub) {
          // disable only the button for the team you followed
          that.disableFollowButton($("button.follow-form[data-faft-id='" + teamId + "']"));
          enableButton(button);
        } else if (that.ui.teamInput.length) {
          // re-enable the button you clicked, as may want to follow a different team
          enableButton(button);
          // if on team page and select to follow the profile team: disable all buttons
          if (that.team && teamId == that.team.get("id")) {
            that.disableAllButtons();
          }
        } else {
          that.disableAllButtons();
        }

        var downloadPopupOptions = {
          teamName: teamName,
          actionType: 'followed',
          teamId: teamId,
          popupType: "on_follow"
        };
        that.customFollowSuccess(teamName, button, type, model, downloadPopupOptions);

        BFApp.vent.trigger("change:state", {
          state: "download"
        });
        BFApp.vent.trigger("goal:complete", {
          goal: 0
        });
        BFApp.vent.trigger("goal:complete", {
          goal: 1
        });

        ActiveApp.CurrentUser.isFollowingFaftTeam = true;

        // try and add the team to the nav dropdown
        var team = App.Modelss.Team.findOrCreate(teamId);
        if (team) ActiveApp.CurrentUserTeams.add(team);

        // Faft ab test end point (team_controller:119)
        if (that.options.abTest) {
          $.ajax({
            url: "/api/v1/split/finished/" + that.options.abTest,
            type: "POST"
          });
        }
      },

      error: function(model, response) {
        errorHandler({
          button: button,
          type: "register",
          response: response
        });
      }
    };

    if (this.isLoggedIn) {
      var ajaxOptions = _.defaults(options, {
        url: "/api/v1/teams/" + teamId + "/follow",
        type: "POST"
      });
      $.ajax(ajaxOptions);
    }
    // check for fb login/signup
    else if (userData.facebook_token) {
      var ajaxOptions = _.defaults(options, {
        url: "/api/v1/users/facebook_registrations?save_type=TEAMFOLLOW&team_id=" + teamId,
        type: "POST",
        data: userData,
      });
      $.ajax(ajaxOptions);
    }
    // else regular signup
    else {
      options.custom = {
        save_type: "TEAMFOLLOW",
        teamId: teamId
      };
      ActiveApp.CurrentUser.set(userData);
      ActiveApp.CurrentUser.save({}, options);
    }

    // goog analytics
    if (!this.isLoggedIn && typeof(window._gaq) !== "undefined") {
      _gaq.push(['_trackEvent', 'follow', 'click']);
    }
  },

  customFollowSuccess: function(teamName, button, type, model, downloadPopupOptions) {
    BFApp.vent.trigger("download-app:show", downloadPopupOptions);
  },

  facebookLogin: function() {
    var that = this;
    disableButton(this.ui.facebookButton);

    // first check if they're already logged in,
    // as in this case, calling FB.login() wont trigger the callback
    FB.getLoginStatus(function(response) {
      //console.log("getLoginStatus Response: "+JSON.stringify(response));
      if (response.status === 'connected') {
        //alert("already got auth token = "+response.authResponse.accessToken);
        that.facebookAuthResponse(response.authResponse.accessToken);
      } else {
        //console.log("calling login");
        FB.login(function(response) {
          //console.log("Login response: "+JSON.stringify(response));
          if (response.authResponse) {
            //alert('login success got auth token = '+response.authResponse.accessToken);
            that.facebookAuthResponse(response.authResponse.accessToken);
          } else {
            //alert('login failed');
            that.facebookAuthResponse(false);
          }
        }, {
          // we need their email address for signup
          scope: 'email'
        });
      }

      // report if the user is already logged-in/authorised perms
      that.followAnalytics("Facebook", response.status);
    });
  },

  facebookAuthResponse: function(token) {
    //alert("facebookLogin returned authToken: "+token);
    if (token) {
      this.sendQuery(this.ui.facebookButton, {
        facebook_token: token
      }, "Facebook");
    } else {
      this.$el.closest(".popup").addClass("fb-dropoff").find(".fb-dropoff-text").removeClass(
        "hide");
      this.ui.facebookButton.addClass("focus");
      enableButton(this.ui.facebookButton);
    }

    this.facebookAuthAnalytics(token);
  },

  facebookAuthAnalytics: function() {
    // override
  }

});
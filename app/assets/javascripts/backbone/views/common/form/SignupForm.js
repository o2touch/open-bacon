BFApp.Views.SignupForm = Marionette.ItemView.extend({

  tagName: "div",

  template: "backbone/templates/common/form/signup_form",

  triggers: {
    "click a[name='login']": "login:clicked"
  },

  events: {
    "submit form": "signup"
  },

  ui: {
    nameInput: "input[name=name]",
    emailInput: "input[name=email]",
    passwordInput: "input[name=password]",
    termsInput: "input[name=terms]",
    signupButton: "button[name=signup]"
  },

  initialize: function(options) {
    this.signupOptions = options.signupOptions;
    this.mustAcceptO2Terms = (ActiveApp.CurrentUser.get("tenant_id") == BFApp.constants.getTenantId("O2 Touch"));
  },

  onShow: function() {
    this.ui.nameInput.select();
    this.$('input, textarea').placeholder();
  },

  validateSignup: function() {
    var name = BFApp.validation.isName({
      htmlObject: this.ui.nameInput
    });
    var email = BFApp.validation.isEmail({
      htmlObject: this.ui.emailInput
    });
    var password = BFApp.validation.isPassword({
      htmlObject: this.ui.passwordInput
    });
    var terms = true;
    if (this.mustAcceptO2Terms) {
      terms = BFApp.validation.validateInput({
        htmlObject: this.ui.termsInput,
        require: true
      });
    }

    return (name && email && password && terms);
  },

  serializeData: function() {
    var showLogin = (typeof(this.options.showLogin) == 'undefined') ? true : this.options.showLogin;

    // check if this user has no name (i.e. it's set to their email)
    // this can happen when signup through paywall
    var name = this.model.get("name");
    if (name == this.model.get("email")) {
      name = "";
    }

    var showLabels = !Boolean(this.options.noLabels);

    return {
      name: name,
      email: this.model.get("email"),
      fbParams: this.getFbParams(),
      fbButtonText: this.getFbButtonText(),
      submitButtonText: this.getSubmitButtonText(),
      title: this.options.title,
      showLogin: showLogin,
      showTermsLink: this.mustAcceptO2Terms,
      showFacebook: !ActiveApp.CurrentUser.needsPassword(),
      showLabels: showLabels,
      namePlaceholder: (showLabels) ? "Joe Bloggs" : "Name",
      emailPlaceholder: (showLabels) ? "joe@bloggs.com" : "Email",
      passwordPlaceholder: (showLabels) ? "" : "Password",
      submitClasses: this.options.submitClasses || ""
    };
  },

  getFbButtonText: function() {
    if (this.options.facebookButtonCopy) {
      return this.options.facebookButtonCopy;
    }
    if (ActiveApp.CurrentUser.isLoggedIn() && ActiveApp.CurrentUser.isInvited()) {
      return "Confirm with Facebook";
    }
    return "Sign up with facebook";
  },

  getSubmitButtonText: function() {
    if (this.options.signupButtonCopy) {
      return this.options.signupButtonCopy;
    }
    if (ActiveApp.CurrentUser.isLoggedIn() && ActiveApp.CurrentUser.isInvited()) {
      return "Confirm";
    }
    return "Sign up";
  },

  getFbParams: function() {
    var fbParams;
    var saveType = this.signupOptions.save_type;

    if (this.signupOptions.save_type == "USERCLAIMLEAGUE") {
      fbParams = "save_type=USERCLAIMLEAGUE&league_id=" + this.signupOptions.league_id;
    } else if (ActiveApp.CurrentUser.isLoggedIn() && ActiveApp.CurrentUser.isInvited()) {
      fbParams = "save_type=CONFIRM_USER";
    } else if (saveType == "TEAMOPENINVITELINK") {
      var team_id = ActiveApp.ProfileTeam.get('id');
      var token = this.signupOptions.token;
      fbParams = "save_type=" + saveType + "&team_id=" + team_id + "&token=" + token;
    } else if (saveType == "OPENINVITE") {
      var team_id = this.signupOptions.eventReponse.eventModel.get("team").get('id');
      var event_id = this.signupOptions.eventReponse.eventModel.get('id');
      var response_status = this.signupOptions.eventReponse.responseStatus;
      fbParams = "save_type=" + saveType + "&team_id=" + team_id + "&event_id=" + event_id + "&response_status=" + response_status;
    } else if (saveType == "TEAMFOLLOW") {
      fbParams = "save_type=" + saveType;
    } else {
      fbParams = "";
    }

    return fbParams;
  },


  signup: function(e) {
    e.preventDefault();

    if (this.validateSignup()) {
      disableButton(this.ui.signupButton);

      var params = {
        name: this.ui.nameInput.val(),
        email: this.ui.emailInput.val(),
        password: this.ui.passwordInput.val(),
        time_offset: getTimezoneHours()
      };

      // claim league signup
      if (this.signupOptions.save_type == "USERCLAIMLEAGUE") {
        this.claimLeagueSignup(params);
      }
      // paywall signup
      else if (ActiveApp.CurrentUser.needsPassword()) {
        this.userAddingPassword(params);
      }
      // event invite
      else if (this.signupOptions.eventReponse) {
        this.eventInviteSignup(params);
      }
      // team invite
      else {
        this.teamInviteSignup(params);
      }
    }
  },


  claimLeagueSignup: function(params) {
    var that = this;

    this.model.save(params, {
      custom: this.signupOptions,
      success: function() {
        that.options.signupSuccess();
      },
      error: function() {
        errorHandler({
          button: that.ui.signupButton
        });
      }
    });
  },


  userAddingPassword: function(params) {
    var that = this;

    this.model.save(params, {
      success: function() {
        // close popup and godbar
        BFApp.godbar.close();
        BFApp.vent.trigger("popup:close", true);
      },
      error: function() {
        errorHandler({
          button: that.ui.signupButton
        });
      }
    });
  },


  teamInviteSignup: function(params) {
    var that = this;
    var options;

    // team follow button click
    if (this.signupOptions.save_type == "TEAMFOLLOW") {
      options = {
        success: function() {
          // trigger reload to hash url so know to display popup after reload
          goToUrl(ActiveApp.ProfileTeam.getHref() + "#follow-confirm", false);
        },
        custom: this.signupOptions
      };
    }
    // team OIL link
    else if (this.signupOptions.save_type == "TEAMOPENINVITELINK") {
      options = {
        success: function() {
          enableButton(that.ui.signupButton);
          that.trigger("close:popup");
          BFApp.vent.trigger("team-open-invite-link-confirmation-popup:show", ActiveApp.ProfileTeam.get('name'));
        },
        custom: this.signupOptions
      };
    }
    // team email invite
    else {
      options = {
        success: function() {
          enableButton(that.ui.signupButton);
          BFApp.vent.trigger("register:successful");
        },
        custom: {
          save_type: "CONFIRM_USER"
        }
      };
    }

    // common options
    _.extend(options, {
      error: function(model, xhr, options) {
        errorHandler({
          button: that.ui.signupButton,
          errorBox: that.$(".signup-error-alert"),
          message: getErrorMessage(xhr)
        });
      }
    });

    this.model.save(params, options);
  },


  eventInviteSignup: function(params) {
    var that = this;
    //SR - WHY USE CURRENT USER HERE WHEN WE USE THIS.MODEL ELSEWHERE AARGRGRGH!!!
    ActiveApp.CurrentUser = new App.Modelss.User();

    var customParams = {
      save_type: "OPENINVITE"
    };

    // Check for Team Context
    var resp = this.signupOptions.eventReponse;
    if (resp.eventModel.get("team") !== null && resp.eventModel.get("team").get("id") !== null) {
      customParams.team_id = resp.eventModel.get("team").get('id');
    }

    // Need EventId and Response Status
    customParams.event_id = resp.eventModel.get('id');
    customParams.response_status = resp.responseStatus;

    options = {
      success: function() {
        window.location.reload();
      },
      error: function(model, response) {
        // TODO: we should display a custom message to the user if they try to signup with an email address that is already in use
        errorHandler({
          button: that.ui.signupButton
        });
      },
      custom: customParams
    };

    ActiveApp.CurrentUser.save(params, options);

  }

});
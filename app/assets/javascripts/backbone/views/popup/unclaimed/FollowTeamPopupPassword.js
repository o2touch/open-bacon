BFApp.Views.FollowTeamPopupPassword = Marionette.ItemView.extend({

  template: "backbone/templates/popups/follow_team_password",

  className: "paywall-popup-flow-password",

  ui: {
    "tempPassword": ".temp-password",
    "passwordForm": "form[name='change-password']",
    "passwordInput": "input[name='password']",
    "submitButton": "button[name='save']"
  },

  events: {
    "click .exit-popup": "nextStage",
    "click .toggle-edit": "toggleEditMode",
    "submit form": "savePassword"
  },

  serializeData: function() {
    return {
      password: this.options.password,
      teamName: this.options.teamName
    };
  },

  onShow: function() {
    analytics.track("Viewed FAFT Team Paywall Password", {});
  },

  toggleEditMode: function(e) {
    e.preventDefault();
    this.ui.tempPassword.toggleClass("hide");
    this.ui.passwordForm.toggleClass("hide");
    if (!this.ui.passwordForm.hasClass("hide")) {
      this.ui.passwordInput.focus();
    }
  },

  nextStage: function() {
    BFApp.vent.trigger("paywall-flow:next", {
      downloadStage: true
    });
  },

  validateForm: function() {
    var isValidPassword = BFApp.validation.isPassword({
      htmlObject: this.ui.passwordInput
    });

    return isValidPassword;
  },

  savePassword: function(e) {
    var that = this;
    e.preventDefault();

    if (this.validateForm()) {
      disableButton(this.ui.submitButton);

      var attrs = {
        password: this.ui.passwordInput.val()
      };

      ActiveApp.CurrentUser.save(attrs, {
        success: function() {
          that.nextStage();
        },
        error: function() {
          errorHandler({
            button: that.ui.submitButton
          });
        }
      });

      analytics.track("Submitted Change Password Form", {
        context: "FAFT Team Paywall Popup"
      });
    }
  }

});
SFApp.Views.SignupFlowOrganiser = Marionette.ItemView.extend({

  template: "backbone/templates/signup_flow/organiser",

  events: {
    "click button[title='next']": "onSubmit"
  },

  ui: {
    "user_name": "#signup_user_name",
    "user_email": "#signup_user_email",
    "buttonNext": "button[title='next']",
  },

  onSubmit: function(e) {
    var that = this;
    var mobileInput = this.$('#signup_user_mobile_number');

    if (this.validate()) {
      that.$(".cancel").hide();
      disableButton(this.ui.buttonNext);

      var tz = jstz.determine();

      var attributes = {
        name: this.ui.user_name.val().trim(),
        email: this.ui.user_email.val().trim(),
        mobile_number: mobileInput.intlTelInput("getCleanNumber"),
        password: this.$("#signup_user_password").val(),
        time_zone: tz.name()
      };


      var options = {
        success: function(model, response, options) {
          window.location.hash = "#confirmation";
        },
        error: function(model, xhr, options) {
          errorHandler({
            button: that.ui.buttonNext,
            errorBox: that.$(".signup-error-alert"),
            message: getErrorMessage(xhr)
          });
          that.$(".cancel").show();
        },
        custom: {
          save_type: "SIGNUPFLOW",
          team_uuid: this.options.team_uuid
        }
      };

      this.model.save(attributes, options);
    }
    return false;
  },

  validate: function() {
    var name = BFApp.validation.isName({
      htmlObject: this.$("#signup_user_name")
    });
    var email = BFApp.validation.isEmail({
      htmlObject: this.$("#signup_user_email")
    });
    var mobile = BFApp.validation.isMobile({
      htmlObject: this.$("#signup_user_mobile_number")
    });
    var password = BFApp.validation.isPassword({
      htmlObject: this.$("#signup_user_password")
    });
    return (name && email && password && mobile);
  },

  serializeData: function() {
    return {
      team_uuid: this.options.team_uuid
    };
  },

  onRender: function() {
    this.ui.user_name.val(this.model.get('name'));
    this.ui.user_email.val(this.model.get('email'));

    // make placeholders work in shit browsers
    this.$('input, textarea').placeholder();
  },

  onShow: function() {
    this.$('#signup_user_mobile_number').intlTelInput(getIntlTelInputOptions());
    // disable autofocus for shit browsers as it hides the placeholder
    if (!this.ui.user_name.hasClass("placeholder")) {
      this.ui.user_name.select();
    }
  }

});
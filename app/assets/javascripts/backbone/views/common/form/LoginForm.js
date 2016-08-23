BFApp.Views.LoginForm = Marionette.ItemView.extend({

  tagName: "div",

  template: "backbone/templates/common/form/login_form",

  events: {
    "submit form": "login"
  },

  triggers: {
    "click a[name='signup']": "signup:clicked"
  },

  ui: {
    loginEmailInput: "input[name='login-email']",
    loginPasswordInput: "input[name='login-password']",
    loginButton: "button[title='login']",
    loginAlertBox: ".invalid-alert"
  },

  onShow: function() {
    this.ui.loginEmailInput.select();
    this.$('input, textarea').placeholder();
  },

  serializeData: function() {
    return {
      showSignup: this.options.showSignup,
      title: (this.options.title) ? this.options.title : "Login"
    }
  },

  validateLogin: function() {
    var email = BFApp.validation.isEmail({
      htmlObject: this.ui.loginEmailInput
    });

    var password = BFApp.validation.isPassword({
      htmlObject: this.ui.loginPasswordInput
    });

    return (email && password)
  },

  login: function() {
    var that = this;
    if (this.validateLogin()) {

      disableButton(this.ui.loginButton);
      var data = {
        remote: true,
        commit: "Sign in",
        utf8: "✓",
        user: {
          remember_me: 1,
          password: this.ui.loginPasswordInput.val(),
          email: this.ui.loginEmailInput.val()
        },
      };

      $.ajax({
        type: "post",
        url: "/d/users/sign_in.json",
        dataType: 'json',
        headers: {
          "ReturnTo": window.location.href
        },
        data: data,
        success: function(data) {
          goToUrl(data.redirect, true);
          that.trigger("login:success");
          return false;
        },
        error: function(response) {
          var options = {
            button: that.ui.loginButton
          };
          if (response.status == 401) {
            options.message = "Your email/password is incorrect";
          }
          errorHandler(options);
        }
      });
    }

    return false;
  }


});
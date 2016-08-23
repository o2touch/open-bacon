BFApp.Views.LeagueRegisterForm = BFApp.Views.O2TouchRegisterForm.extend({

  customSerializeData: function(data) {
    data.title = "Register to Join the League";
    data.msg = "Enter your details below to register for the league.";
  },

  saveUser: function(e) {
    e.preventDefault();
    var that = this;

    if (this.validateForm()) {
      disableButton(this.ui.submitButton);

      var options = {
        success: function() {
          that.trigger("next", that.ui.submitButton);
        },
        error: function(model, response, options) {
          errorHandler({
            type: "register",
            response: response,
            button: that.ui.submitButton
          });
        }
      };

      if (!this.isLoggedIn) {
        options.custom = {
          save_type: "USER",
          tenantId: BFApp.constants.getTenantId("O2 Touch")
        };
      }

      // use the model's setDOB() for consistency in formatting
      var dob = this.ui.dateInput.val();
      this.model.setDOB(dob);

      this.model.save(this.getAttributes(), options);
    }
  }

});
BFApp.Views.O2TouchRegisterForm = Marionette.ItemView.extend({

  template: "backbone/templates/common/o2_touch_register_form",

  tagName: "form",

  ui: {
    nameInput: "input[name=name]",
    dateInput: "input[name=dob]",
    genderInput: "input[name=gender]",
    phoneInput: "input[name=phone]",
    emailInput: "input[name=email]",
    typeInput: "input[name=type]",
    passwordInput: "input[name=password]",
    termsInput: "input[name=terms]",
    submitButton: "button[name=submit]"
  },

  events: {
    "submit": "saveUser",
    "click a[name=close]": "closePopup"
  },

  initialize: function(options) {
    this.isLoggedIn = this.model.isLoggedIn();
  },

  serializeData: function() {
    var data = {
      name: this.model.get("name"),
      email: this.model.get("email"),
      phone: this.model.get("mobile_number"),
      dob: this.model.getDOB(),
      isLoggedIn: this.isLoggedIn
    };
    this.customSerializeData(data);
    return data;
  },

  onRender: function() {
    var gender = this.model.get("gender");
    if (gender) {
      this.ui.genderInput.filter("[value=" + gender + "]").prop("checked", true);
    }
  },

  onShow: function() {
    this.ui.phoneInput.intlTelInput(getIntlTelInputOptions("gb"));
  },

  validateForm: function() {
    var isName, isEmail, isPassword;

    if (this.isLoggedIn) {
      isName = isEmail = isPassword = true;
    } else {
      isName = BFApp.validation.isName({
        htmlObject: this.ui.nameInput
      });
      isEmail = BFApp.validation.isEmail({
        htmlObject: this.ui.emailInput
      });
      isPassword = BFApp.validation.isPassword({
        htmlObject: this.ui.passwordInput
      });
    }

    var isDOB = BFApp.validation.isDate({
      htmlObject: this.ui.dateInput,
      require: true
    });
    var hasGender = BFApp.validation.validateInput({
      htmlObject: this.ui.genderInput,
      require: true
    });
    var isPhone = BFApp.validation.isMobile({
      htmlObject: this.ui.phoneInput
    });
    var hasType = BFApp.validation.validateInput({
      htmlObject: this.ui.typeInput,
      require: true
    });
    var isTerms = BFApp.validation.validateInput({
      htmlObject: this.ui.termsInput,
      require: true
    });

    return (isName && isDOB && hasGender && isPhone && isEmail && hasType && isPassword && isTerms);
  },

  saveUser: function(e) {
    // override this
  },

  getAttributes: function() {
    var attrs = {
      gender: this.ui.genderInput.filter(":checked").val(),
      tenanted_attrs: {
        player_history: this.ui.typeInput.filter(":checked").val()
      }
    };

    if (!this.isLoggedIn) {
      attrs.name = this.ui.nameInput.val();
      attrs.email = this.ui.emailInput.val();
      attrs.password = this.ui.passwordInput.val();
    }

    var mobile = this.ui.phoneInput.intlTelInput("getCleanNumber");
    if (mobile) {
      attrs.mobile_number = mobile;
    }

    return attrs;
  },

  closePopup: function() {
    BFApp.vent.trigger("popup:close");
  }

});
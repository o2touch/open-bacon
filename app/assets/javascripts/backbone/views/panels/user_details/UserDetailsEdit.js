BFApp.Views.UserDetailsEdit = Marionette.ItemView.extend({

  tagName: "form",

  template: "backbone/templates/panels/user_details/user_details_edit_profile",

  className: "edit-settings",

  events: {
    "keyup #user-profile-bio": "limit",
    "submit": "save",
    "click .link-cancel": "cancel",
  },

  ui: {
    "name": "#user-name",
    "dob": "input[name=dob]",
    "gender": "input[name=gender]",
    "username": "#user-username",
    "email": "#user-email",
    "bio": "#user-profile-bio",
    "bioLimit": ".limit",
    "timeZone": "#user-time-zone",
    "mobile": "#user-mobile-number",
    "uploadButton": "button[name='upload-button']",
    "thumb": ".pfl-pic-section img",
    "fileInput": "input[name='user-profile-picture']",
    "buttonSave": "button[title='save']"
  },

  serializeData: function() {
    return {
      profilePicHtml: this.model.getPictureHtml("small"),
      timeZoneList: BFApp.constants.timeZones,
      timeZoneUser: this.model.get("time_zone"),
      name: this.model.get("name"),
      dob: this.model.getDOB(),
      bio: this.model.get("bio"),
      userName: this.model.get("username"),
      email: this.model.get("email"),
      mobile: this.model.get("mobile_number"),
      junior: this.model.isJunior()
    };
  },

  limit: function() {
    var bioLength = this.ui.bio.val().length,
      max = 120;
    if (bioLength > max) {
      this.ui.bioLimit.removeClass("hide").addClass("error").text("Characters exceeded: " + (bioLength - max));
    } else if (bioLength == max) {
      this.ui.bioLimit.addClass("hide").text("");
    } else if (bioLength < max) {
      this.ui.bioLimit.removeClass("hide error").text("Characters remaining: " + (bioLength - max) * -1);
    }
  },

  onRender: function() {
    this.bindPictureUploader();
    this.limit();

    // set gender
    var gender = this.model.get("gender");
    if (gender) {
      this.ui.gender.filter("[value=" + gender + "]").prop("checked", true);
    }

    // make placeholders work in shit browsers
    this.$('input, textarea').placeholder();
  },

  onShow: function() {
    if (!this.model.isJunior()) {
      this.ui.mobile.intlTelInput(getIntlTelInputOptions());
    }
  },

  bindPictureUploader: function() {
    var action = '/users/' + this.model.get("id") + '/upload_profile_picture';
    initFileUploader(this.ui.uploadButton, this.ui.thumb, action, this.model);
  },

  validate: function() {
    var username, email, mobile;

    var name = BFApp.validation.isName({
      htmlObject: this.ui.name,
      require: true
    });

    var bio = BFApp.validation.validateInput({
      htmlObject: this.ui.bio,
      maximumLength: 120,
      require: false
    });

    var dob = BFApp.validation.isDate({
      htmlObject: this.ui.dob,
      require: false
    });

    if (!this.model.isInvited()) {
      username = BFApp.validation.isUsername({
        htmlObject: this.ui.username
      });
    } else {
      username = true;
    }

    if (!this.model.isJunior()) {
      email = BFApp.validation.isEmail({
        require: true,
        htmlObject: this.ui.email
      });

      mobile = BFApp.validation.isMobile({
        htmlObject: this.ui.mobile,
        require: false
      });

    } else {
      email = true;
      mobile = true;
    }

    return (name && email && mobile && username && bio && dob);
  },

  cancel: function(e) {
    e.preventDefault();
    this.trigger("close:popup");
  },

  save: function(e) {
    e.preventDefault();
    var that = this;

    if (!ActiveApp.CurrentUser.isInLimbo() && !this.validate()) {
      return false;
    }

    disableButton(this.ui.buttonSave);

    var attrs = {};
    if (!ActiveApp.CurrentUser.isInLimbo()) {

      // use the model's setDOB() for consistency in formatting
      var dob = this.ui.dob.val();
      this.model.setDOB(dob);

      $.extend(attrs, {
        name: this.ui.name.val().trim(),
        username: this.ui.username.val().trim(),
        bio: this.ui.bio.val().trim(),
        profile_picture: this.ui.fileInput.val(),
        time_zone: this.ui.timeZone.val()
      });

      var selectedGender = this.ui.gender.filter(":checked");
      if (selectedGender.length) {
        attrs.gender = selectedGender.val();
      }

      if (!this.model.isJunior()) {
        $.extend(attrs, {
          email: this.ui.email.val().trim(),
          mobile_number: this.ui.mobile.intlTelInput("getCleanNumber")
        });
      }
    }

    this.model.save(attrs, {
      success: function(model, response) {
        that.trigger("close:popup");
      },

      error: function(model, xhr, options) {
        var errorOptions = {
          button: that.ui.buttonSave
        };

        errorHandler(errorOptions);
      }
    });
  }

});
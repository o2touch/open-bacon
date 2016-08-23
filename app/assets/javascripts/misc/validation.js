BFApp.validation = {

  /**
   * NOTE: these must only be 1 line else the message will completely cover the input!
   */
  msg: {
    nameBlank: "Name can't be blank!",
    nameCheck: "Oops! Name contains illegal characters.",
    nameLength: "Name should be between 3 and 25 letters!",

    emailBlank: "Email can't be blank",
    emailRegex: "Email doesn't look right",

    mobileBlank: "Phone number can't be blank",
    mobileRegex: "Must start with a + and can't contain any illegal characters",
    mobileLength: "Phone number should be between 5 and 15 numbers!",
    mobileType: "Must be a mobile number",

    bioLength: "Oops! Your biography seems quite long!",

    teamNameLength: "Oops! Your team name should be between 3 and 30 letters!",
    teamNameRegex: "Oops! Your team name contains illegal characters.",

    titleLength: "Title should be between 3 and 100 letters!",
    titleRegex: "Title contains illegal characters.",

    usernameBlank: "Oops! You have to choose a username.",
    usernameLength: "Oops! Your username should be between 3 and 25 letters!",
    usernameRegex: "Username should only contain letters, numbers and hyphens!",

    scoreBlank: "Score can't be blank!",
    scoreRegex: "Score can only contain numbers and letters",
    scoreLength: "Score should not exceed 5 characters",

    passwordBlank: "Password can't be blank!",
    passwordLength: "Your password should be at least 6 letters!",

    passwordConfirmationBlank: "Oops! We need that information!",
    passwordNotMatch: "The two passwords don't match!",

    eventTitleBlank: "Title can't be blank!",
    eventTitleRegex: "Your event name contains illegal characters.",
    eventTitleLength: "Your event title should not exceed 50 letters!",

    locationBlank: "You must set a location!",
    locationModelInvalid: "Location not found. Please re-type and select one of the suggestions.",

    fixtureTitleBlank: "If both teams are still TBC, you must set a title!",
    fixtureTitleRegex: "Fixture name contains illegal characters.",
    fixtureTitleLength: "Fixture title should not exceed 50 letters!",

    commentLength: "Oops! Comments cannot be that long!",
    commentBlank: "Oops! Comments cannot be empty!",
    messageLength: "Oops! Messages cannot be that long!",
    messageBlank: "Oops! Messages cannot be empty!",

    adjustmentAmountRegex: "Invalid number",
    genericNumberRegex: "Invalid number",

    genericRequired: "Required",
    genericFormat: "Invalid format",
    genericInvalid: "Invalid"
  },

  regex: {
    // names contain upper+lower case letters (inc weird European chars),
    // spaces, hyphens, apostrophes
    name: new RegExp(/^[-'a-zA-ZZÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ ]+$/),


    /* 
      Previous email regex (from http://stackoverflow.com/a/46181/217866)
      var _emailRegex = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
      Problem: Was letting invalid email such as prado.igna@gmail.com.
    
      I've copied the convert to JS the one from here => http://www.regular-expressions.info/email.html
    
    */
    email: new RegExp(/^[a-z0-9!#$%&'*+[\]\\=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+[\]\\=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/i),
    // mobile numbers start with a plus, then contain one or more: numbers, spaces, brackets, hyphens, dots
    mobile: new RegExp(/^\+[\d \(\)-.]+$/),
    // usernames are alphanumerical with hyphens
    username: new RegExp(/^[a-zA-Z][a-zA-Z0-9-]+$/),
    // team/league names contain upper+lower case letters (inc weird European chars),
    // spaces, numbers, ampersands, brackets, hyphens, apostrophes, commas
    teamName: new RegExp(/^[-'\(\)&,0-9a-zA-ZZÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ ]+$/),
    // alphanumeric regex used for score validation
    alphanum: new RegExp(/^[a-z0-9]+$/),
    // numeric regex
    num: new RegExp(/^(-)?[0-9]+$/),
    // numeric regex (positive)
    positiveNum: new RegExp(/^[0-9]+$/),
    // numeric regex (cant be 0)
    // new: can start with "+" because ben expected to be able to do this for the points adjustments
    nonZeroNum: new RegExp(/^[-+]?[1-9][0-9]*$/)
  },


  isName: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.nameBlank,
      regex: this.regex.name,
      regexMessage: this.msg.nameCheck,
      minimumLength: 3,
      minimumLengthMessage: this.msg.nameLength,
      maximumLength: 25,
      maximumLengthMessage: this.msg.nameLength
    });

    return this.validateInput(options);
  },

  isUsername: function(options) {
    _.defaults(options, {
      require: true, // JO+PR decided we would leave this as required, and generate a default one on registration, like fb
      requireMessage: this.msg.usernameBlank,
      regex: this.regex.username,
      regexMessage: this.msg.usernameRegex,
      minimumLength: 3,
      minimumLengthMessage: this.msg.usernameLength,
      maximumLength: 25,
      maximumLengthMessage: this.msg.usernameLength
    });

    return this.validateInput(options);
  },

  isPassword: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.passwordBlank,
      minimumLength: 6,
      minimumLengthMessage: this.msg.passwordLength
    });

    return this.validateInput(options);
  },

  isEmail: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.emailBlank,
      regex: this.regex.email,
      regexMessage: this.msg.emailRegex
    });

    return this.validateInput(options);
  },

  isMobile: function(options) {
    var type = options.htmlObject.intlTelInput("getNumberType"),
      isMobileType = (type == intlTelInputUtils.numberType.MOBILE || type == intlTelInputUtils.numberType.FIXED_LINE_OR_MOBILE);

    _.defaults(options, {
      isValid: options.htmlObject.intlTelInput("isValidNumber"),
      regexMessage: this.msg.genericInvalid,
      customFormat: function() {
        return isMobileType;
      },
      formatMessage: this.msg.mobileType
    });

    return this.validateInput(options);
  },

  isDate: function(options) {
    _.defaults(options, {
      dateFormat: "DD/MM/YYYY"
    });

    options.customFormat = function(val) {
      return moment(val, options.dateFormat, true).isValid();
    };

    return this.validateInput(options);
  },

  isScore: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.scoreBlank,
      regex: this.regex.positiveNum,
      regexMessage: this.msg.genericNumberRegex,
      maximumLength: 5,
      maximumLengthMessage: this.msg.scoreLength
    });

    return this.validateInput(options);
  },

  isComment: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.commentBlank,
      maximumLength: 4000,
      maximumLengthMessage: this.msg.commentLength
    });

    return this.validateInput(options);
  },

  isMessage: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.messageBlank,
      maximumLength: 4000,
      maximumLengthMessage: this.msg.messageLength
    });

    return this.validateInput(options);
  },

  isTeamName: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.nameBlank,
      regex: this.regex.teamName,
      regexMessage: this.msg.teamNameRegex,
      minimumLength: 3,
      minimumLengthMessage: this.msg.teamNameLength,
      maximumLength: 30,
      maximumLengthMessage: this.msg.teamnameLength
    });

    return this.validateInput(options);
  },

  isEventName: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.eventTitleBlank,
      regex: this.regex.teamName,
      regexMessage: this.msg.eventTitleRegex,
      maximumLength: 50,
      maximumLengthMessage: this.msg.eventTitleLength
    });

    return this.validateInput(options);
  },

  isLocation: function(options) {
    _.defaults(options, {
      require: false,
      requireField: "title",
      requireMessage: this.msg.locationBlank,
      modelMessage: this.msg.locationModelInvalid
    });

    return this.validateInput(options);
  },

  isFixtureTitle: function(options) {
    _.defaults(options, {
      require: true,
      requireMessage: this.msg.fixtureTitleBlank,
      regex: this.regex.teamName,
      regexMessage: this.msg.fixtureTitleRegex,
      maximumLength: 70,
      maximumLengthMessage: this.msg.fixtureTitleLength
    });

    return this.validateInput(options);
  },

  isTitle: function(options) {
    _.defaults(options, {
      require: false,
      regex: this.regex.teamName,
      regexMessage: this.msg.titleRegex,
      minimumLength: 3,
      minimumLengthMessage: this.msg.titleLength,
      maximumLength: 100,
      maximumLengthMessage: this.msg.titleLength,
    });

    return this.validateInput(options);
  },



  validateInput: function(options) {
    // we need this
    if (!options.htmlObject || !options.htmlObject.length) {
      return false;
    }

    _.defaults(options, {
      showError: true,
      alertBox: true,
      requireMessage: this.msg.genericRequired,
      formatMessage: this.msg.genericFormat
      // NOTE: no point in putting negative values here as their absense is equivalent
    });

    // remove prev error
    this.removeValidationError(options);

    var val;
    if (options.model && options.requireField) {
      val = options.model.get(options.requireField);
    } else if (options.htmlObject.attr("type") == "radio") {
      val = options.htmlObject.filter(":checked").val();
    } else if (options.htmlObject.attr("type") == "checkbox") {
      val = options.htmlObject.filter(":checked").length; // equivalent of a boolean
    } else {
      val = options.htmlObject.val();
    }

    // only run tests if there's a value
    if (val) {

      if ("isValid" in options && !options.isValid) {
        this.displayValidationError(options, options.regexMessage);
        return false;
      }

      // check custom formatting
      if (options.customFormat && !options.customFormat(val)) {
        this.displayValidationError(options, options.formatMessage);
        return false;
      }

      // check regex
      if (options.regex && !options.regex.test(val)) {
        this.displayValidationError(options, options.regexMessage);
        return false;
      }

      // check model e.g. location
      if (options.model && !options.model.isValid()) {
        this.displayValidationError(options, options.modelMessage);
        return false;
      }

      // check isEqualTo
      if (options.isEqualTo && options.isEqualTo.val() !== val) {
        this.displayValidationError(options, options.isEqualToMessage);
        return false;
      }

      // min length
      if (options.minimumLength && val.length < options.minimumLength) {
        this.displayValidationError(options, options.minimumLengthMessage);
        return false;
      }

      // max length
      if (options.maximumLength && val.length > options.maximumLength) {
        this.displayValidationError(options, options.maximumLengthMessage);
        return false;
      }
    } else if (options.require) {
      this.displayValidationError(options, options.requireMessage);
      return false;
    }

    return true;
  },


  displayValidationError: function(options, errorMessage) {
    if (options.showError) {
      // if we're dealing with radios, just use the parent
      var inputContainer = (options.htmlObject.attr("type") == "radio") ? options.htmlObject.closest(".radio-group") : $("#" + options.htmlObject.attr("id") + "-container");
      if (inputContainer.length) {
        inputContainer.addClass("error");
      } else {
        options.htmlObject.addClass("error");
      }

      if (options.alertBox && errorMessage) {
        var errorMsg = "<div class='alert-box alert'>" + errorMessage + "</div>";
        // if specify errorOnForm, prepend the error to the form element 
        if (options.errorOnForm) {
          var form = options.htmlObject.closest("form");
          if (form.length) {
            form.prepend(errorMsg);
          }
        } else if (inputContainer.length) {
          // if the input has it's own special container div, prepend the error message in there
          // else put it just before the input itself
          inputContainer.prepend(errorMsg);
        } else {
          // else put it just before the input itself
          options.htmlObject.before(errorMsg);
        }
      }
    }
  },


  removeValidationError: function(options) {
    // if we're dealing with radios, just use the parent
    var inputContainer = (options.htmlObject.attr("type") == "radio") ? options.htmlObject.closest(".radio-group") : $("#" + options.htmlObject.attr("id") + "-container");
    if (inputContainer.length) {
      inputContainer.removeClass("error");
      inputContainer.children(".alert-box").remove();
    } else {
      options.htmlObject.removeClass("error");
      options.htmlObject.prev(".alert-box").remove();
    }
  }

};
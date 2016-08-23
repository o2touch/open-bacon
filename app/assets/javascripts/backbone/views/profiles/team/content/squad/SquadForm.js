BFApp.Views.SquadForm = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_form",

  className: "squad-form",

  tagName: "form",

  triggers: {
    "click a[title='cancel']": "cancel:clicked"
  },

  events: {
    "submit": "save",
    "change input[name='junior']": "juniorForm",
    "change input[name='i-am-parent']": "setIamParent",
    "keyup input[name='player-name']": "mimicName",
    "keyup input[name='parent-name']": "mimicParent"
  },

  ui: {
    nameInput: "input[name='player-name']",
    emailInput: "input[name='email']",
    mobileInput: "#user-mobile-number",
    teamSelect: "select[name=team]",
    parentName: "input[name='parent-name']",
    parentEmail: "input[name='parent-email']",
    iamParentInput: "input[name='i-am-parent']",
    parentDetails: ".parent-details-collapsible",
    saveButton: "button[name='save']"
  },

  serializeData: function() {
    return {
      model: this.model,
      junior: this.showJuniorFields(),
      secondParent: this.options.secondParent,
      showTeams: (this.options.context == "league_admin"),
      teams: this.options.teams
    };
  },

  onRender: function() {
    // make placeholders work in shit browsers
    this.$('input, textarea').placeholder();

    if (this.options.context == "league_admin") {
      this.ui.saveButton.html('Save');
      this.ui.saveButton.data('disabled', 'Saving');
    }
  },

  mimicName: function(e) {
    // this.model.set("name", $(e.currentTarget).val());
  },

  mimicParent: function(e) {
    this.model.set("parent_name", $(e.currentTarget).val());
  },

  onShow: function() {
    this.ui.mobileInput.intlTelInput(getIntlTelInputOptions());
    if (!this.ui.nameInput.hasClass("placeholder")) {
      this.ui.nameInput.select();
    }
  },

  /* PR - Added this in so that SquadForm can be used without ActiveApp.ProfileTeam
     This is a bit of a hack. Idealy this dependency should not exist */
  showJuniorFields: function() {
    if (ActiveApp.ProfileTeam) {
      return ActiveApp.ProfileTeam.isJuniorTeam();
    }
    return false;
  },

  setIamParent: function() {
    var that = this;

    if (this.ui.iamParentInput.is(':checked')) {

      this.ui.parentDetails.slideUp(function() {
        var name = ActiveApp.CurrentUser.get("name");
        var email = ActiveApp.CurrentUser.get("email");
        var mobile = ActiveApp.CurrentUser.get("mobile");
        that.setParentDetails(name, email, mobile);
      });
    } else {
      this.setParentDetails("", "", "");
      this.ui.parentDetails.slideDown();
    }
  },

  setParentDetails: function(name, email, mobile) {
    this.ui.parentName.val(name);
    this.ui.parentEmail.val(email);
    this.ui.mobileInput.val(mobile);
  },

  juniorForm: function() {
    if (this.showJuniorFields()) {
      this.$(".adult").addClass("hide");
      this.$("fieldset").removeClass("hide");
    } else {
      this.$(".adult").removeClass("hide");
      this.$("fieldset").addClass("hide");
    }

  },

  validate: function() {
    var name = BFApp.validation.isName({
      htmlObject: this.ui.nameInput
    });

    var mobile = BFApp.validation.isMobile({
      htmlObject: this.ui.mobileInput
    });

    var parentName, email;
    if (this.showJuniorFields()) {
      parentName = BFApp.validation.isName({
        htmlObject: this.ui.parentName
      });
      email = BFApp.validation.isEmail({
        htmlObject: this.ui.parentEmail
      });
    } else {
      parentName = true;
      email = BFApp.validation.isEmail({
        htmlObject: this.ui.emailInput
      });
    }

    return (name && email && mobile && parentName);
  },

  save: function(e) {
    e.preventDefault();
    var that = this;

    if (this.validate()) {
      disableButton(this.ui.saveButton);

      var attrs = {
        name: this.ui.nameInput.val().trim()
      };

      /* PR - Added this in so that SquadForm can be used without ActiveApp.ProfileTeam
         This is a bit of a hack. Ideally this dependency should not exist */
      var customParams = {};
      if (ActiveApp.ProfileTeam) {
        customParams.team_id = ActiveApp.ProfileTeam.get("id");
      }

      if (this.showJuniorFields()) {
        attrs.email = this.ui.parentEmail.val().trim();
        attrs.mobile_number = this.ui.mobileInput.intlTelInput("getCleanNumber");
        attrs.parent_name = this.ui.parentName.val().trim();
        customParams.save_type = "JUNIOR";
      } else {
        attrs.email = this.ui.emailInput.val().trim();
        attrs.mobile_number = this.ui.mobileInput.intlTelInput("getCleanNumber");
        customParams.save_type = "TEAMPROFILE";
      }

      var options = {
        custom: customParams,
        error: function(model, xhr, options) {
          errorHandler({
            button: that.ui.saveButton,
            message: getErrorMessage(xhr)
          });
        }
      };

      /* This switch on 'context' is a hack to save refactoring this whole view
         Ideally this should be extracted from the view and the callback 
         functions should be passed in from the parent view - PR */
      if (this.options.context == "league_admin") {
        customParams.team_id = this.ui.teamSelect.val();
        _.extend(options, {
          success: function(model) {
            BFApp.vent.trigger("squad:form:add:player", model);
            // close sidebar
            that.trigger("cancel:clicked");
          }
        });
      } else {
        _.extend(options, {
          success: function(data) {
            enableButton(that.ui.saveButton);

            if (that.showJuniorFields()) {
              var junior = data.get("0");
              var parent = data.get("1");

              // no way to check if junior already exists in team (kids use parent's emails)
              ActiveApp.Teammates.add(junior, {
                merge: true,
                parse: true
              });
              ActiveApp.Teammates.add(parent, {
                merge: true,
                parse: true
              });
            } else {
              ActiveApp.Teammates.add(that.model, {
                parse: true
              });
            }

            that.trigger("add-player");
          }
        });
      }

      this.model.save(attrs, options);
    }

    return false;
  }
});
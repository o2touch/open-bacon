BFApp.Views.EventInformationsEditPanel = Marionette.ItemView.extend({

  template: "backbone/templates/panels/event_informations_edit_panel",

  tagName: "form",

  className: "classic",

  events: {
    "click .close-panel": "onBeforeCancel",
    "submit": "save",
    "keyup #eventTitle": "syncTitle",
    "change #event-type": "onChangeEventType"
  },

  ui: {
    gameTypeInput: "#event-type",
    titleInput: "#eventTitle",
    saveButton: ".save-event"
  },

  initialize: function() {
    this.model.store();
  },

  serializeData: function() {
    return {
      title: this.model.get("title"),
      gameType: this.model.get("game_type"),
      extraFields: this.model.get("team").get("event_extra_fields"),
      gameDisplayName: ActiveApp.Tenant.get("general_copy").game_display_name
    };
  },

  // declare this as a function so we have access to the view's context object
  templateHelpers: function() {
    var that = this;

    return {
      // use this to get arbitrary attributes from the model when we are processing event_extra_fields which could reference any attribute 
      getExtraFieldValue: function(field) {
        return that.model.get(field);
      }
    };
  },

  // JO - disabling this (after checking with LG) because we're going to have an arbitrary set of fields in this form now, so too hard to check them all
  /*compareData: function() {
    if (this.ui.gameTypeInput.val() == this.model.storedAttributes.game_type && this.ui.titleInput.val() == this.model.storedAttributes.title) {
      this.ui.saveButton.prop("disabled", true);
    } else {
      this.ui.saveButton.prop("disabled", false);
    }
  },*/

  /*onShow: function() {
    this.compareData();
  },*/

  setEventTitleAttributes: function() {
    if (this.ui.gameTypeInput.val() == 1) {
      this.ui.titleInput.prop("disabled", true);
    } else {
      this.ui.titleInput.prop("disabled", false);
    }
  },

  onChangeEventType: function() {
    if (this.ui.gameTypeInput.val() == 1) {
      this.ui.titleInput.val("Practice");
    } else {
      this.ui.titleInput.val(this.model.get("title"));
    }
    this.setEventTitleAttributes();
    //this.compareData();
  },

  syncTitle: function() {
    this.model.set({
      "title": this.ui.titleInput.val()
    });
    //this.compareData();
  },

  changeEventType: function() {
    if (this.$("#event-type").val() == 1) {
      this.$("#eventTitle").prop("disabled", true).val("practice").animate({
        "opacity": 0.2
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
    } else {
      this.$("#eventTitle").prop("disabled", false).val("title").animate({
        "opacity": 1
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingOut);
    }
  },

  onBeforeCancel: function() {
    this.model.restore();
    this.trigger("dismiss");
    return false;
  },

  save: function(e) {
    e.preventDefault();
    var that = this;

    if (this.model.validateEdit(this.ui.titleInput)) {
      disableButton(this.ui.saveButton);

      var params = {
        title: this.ui.titleInput.val().trim(),
        game_type: this.ui.gameTypeInput.val(),
      };

      // check for extra fields
      _.each(this.model.get("team").get("event_extra_fields"), function(field) {
        if (field.element == "input") {
          params[field.name] = that.$("[name='" + field.name + "']").val();
        }
      });

      this.model.save(params, {
        success: function(model, response, options) {
          that.trigger("dismiss");
          enableButton(that.ui.saveButton);
        },
        error: function(model, response, options) {
          errorHandler();
        },
        notify: 1
      });
    }
  }

});
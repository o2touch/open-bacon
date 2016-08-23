/**
 * This is used on the Team page, in edit schedule mode
 */
BFApp.Views.ScheduleEventEdit = BFApp.Views.ScheduleRowEdit.extend({

  template: "backbone/templates/profiles/team/widget/events_edit/schedule_event_edit",

  className: "panel schedule-edit event-edit-detail",

  events: {
    // fields
    "change #prev-locations": "selectedLocation",
    "click #toggle-location-mode": "toggleLocationMode",
    // repeat
    "click .show-repeat": "hideRepeat",
    "click .cancel-repeat": "showRepeat",
    "change #repeat-type": "changeRepeatCopy",
    "change #repeat-number": "changeRepeatCopy",
    // sync
    "change #edit-event-type": "changeType",
    "keyup #edit-event-title": "syncTitle",
    "keyup #edit-location": "syncLocation",
    "change #edit-event-date, #edit-event-hours, #edit-event-minutes, #edit-event-ampm": "syncDate",
    // actions
    "click button[title='save']": "save",
    "click .cancel-link": "cancelEdit",
    "click button[title='cancel event']": "cancelEvent",
    "click button[name='re-enable']": "enableEvent",
    "click .remove-event": "removeEvent",
    "click .postpone-event": "showPostponeEdit",
  },

  ui: {
    // repeat
    "repeatForm": ".repeat-form",
    "repeatButton": ".show-repeat",
    "repeatType": "#repeat-type",
    "repeatNumber": "#repeat-number",
    // fields
    "eventType": "#edit-event-type",
    "title": "#edit-event-title",
    "hours": "#edit-event-hours",
    "minutes": "#edit-event-minutes",
    "ampm": "#edit-event-ampm",
    "date": "#edit-event-date",
    //"responseRequired": "#edit-event-response-required",
    // location - NOTE: some of these are only used in ScheduleRowEdit
    "locationFieldOptions": ".location-field-options",
    "locationInputGroup": ".location-input-group",
    "locationTitle": "#edit-location",
    "locationSearch": "button[name=location-search]",
    "locationMap": "#mapwrapper",
    "locationsDropdown": "#prev-locations",
    "toggleLocationLink": "#toggle-location-mode",
    // actions
    "saveButton": "button[title='save']",
    "cancelButton": "button[title='cancel event']",
    "enableButton": "button[name='re-enable']"
  },

  initialize: function(options) {
    // used in ScheduleRowEdit.js
    this.rowType = "event";
    this.repeatVisible = false;
    this.locations = options.locations;

    // store the current state of the model, so we can restore it on cancel
    if (this.model.get("id")) {
      this.model.store();
    }

    // if editing an event w/o a location, and no existing locations to choose from,
    // we must give it a blank one to "edit"
    if (!this.model.get("location") && this.locations.length === 0) {
      this.model.set("location", new App.Modelss.Location());
    }
  },

  showPostponeEdit: function() {
    var that = this;
    var postponeEventPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "login",
      panelTitle: "Postpone Event",
      extendClass: "re-schedule popover"
    });
    this.$(".schedule-postpone-container").html("").append(postponeEventPanelView.render().el);

    var postPoneContentView = new BFApp.Views.ScheduleEditPanel({
      model: this.model,
      postponeMode: true
    });


    postPoneContentView.on("dismiss", function() {
      that.$(".schedule-postpone-container").html("");
      that.trigger(that.rowType + ":close");
    });

    postponeEventPanelView.showContent(postPoneContentView);
    postPoneContentView.initPlugins();

    return false;
  },


  changeType: function() {
    // set this on the model, to trigger a change event and re-render it
    var gameTypeString = this.ui.eventType.children(":selected").text().toLowerCase();
    this.model.set("game_type_string", gameTypeString);

    var title, disableVal;
    if (this.ui.eventType.val() == 1) {
      title = "Practice";
      disableVal = true;
    } else {
      title = "";
      disableVal = false;
    }
    this.ui.title.val(title);
    this.model.set("title", title);
    this.ui.title.prop("disabled", disableVal);
  },

  serializeData: function() {
    var date = this.model.getDateObj();
    var time = date.get12hrTimeObject();

    // default to false
    /*var responseRequired = false;
    if (typeof this.model.get("response_required") !== "undefined") {
      responseRequired = this.model.get("response_required");
    }*/

    return {
      type: this.model.get("game_type"),
      typeString: this.model.get("game_type_string"),
      title: this.model.get("title"),
      locations: this.locations,
      location: this.model.get("location"),
      hours: time.hours,
      minutes: time.minutes,
      ampm: time.ampm,
      date: date.toDateString(),
      status: this.model.get("status"),
      isNewEvent: (this.model.get("id") == null),
      //responseRequired: responseRequired,
      extraFields: ActiveApp.ProfileTeam.get("event_extra_fields"),
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

  removeEvent: function() {
    this.removeRow("Are you sure that you want to remove this event?");
    return false;
  },

  save: function() {
    var compulsoryFields = ActiveApp.ProfileTeam.get("event_compulsory_fields"),
      locationRequired = _.contains(compulsoryFields, "location");

    if (this.model.validateEdit(this.ui.title, this.ui.locationFieldOptions, locationRequired)) {
      var that = this;

      // repeat
      var numEvents = 1;
      var repeatType;
      if (this.ui.repeatForm.is(":visible")) {
        numEvents = parseInt(this.ui.repeatNumber.val(), 10);
        repeatType = this.ui.repeatType.val();
      }

      var date = this.getDateTime();
      var attributes = {
        game_type: this.ui.eventType.val(),
        title: this.ui.title.val().trim(),
        location: this.model.getSaveLocation(),
        time_local: date.toCustomISO(),
        //response_required: this.ui.responseRequired.is(":checked")
      };

      // check for compulsory fields
      _.each(ActiveApp.ProfileTeam.get("event_extra_fields"), function(field) {
        if (field.element == "input") {
          attributes[field.name] = that.$("[name='" + field.name + "']").val();
        }
      });

      // update the fake event in the list
      this.model.set(attributes);

      // analytics
      if ((this.model.get("id") == null)) {
        analytics.track('Clicked add event', {
          "repeats": numEvents,
          //"response_required": attributes.response_required
        });
      }

      disableButton(this.ui.saveButton);

      // if adding repeat events, show a progress popup
      if (numEvents > 1) {
        BFApp.vent.trigger("repeat-events-popup:show", numEvents);
      }

      // keep track of which models have been successfully saved to the server
      this.savedModels = 0;

      for (var i = 0; i < numEvents; i++) {

        // after the first iteration, we're dealing with repeats, so we must update the date
        if (i > 0) {
          if (repeatType == "m") {
            date.add("months", 1);
          } else if (repeatType == "w") {
            date.add("weeks", 1);
          }

          attributes.time_local = date.toCustomISO();
        }

        var options = {
          success: function(model, response, options) {
            that.modelSaved(model, numEvents);
          },
          error: function(model, response, options) {
            errorHandler({
              button: that.ui.saveButton
            });
          }
        };

        // if creating new event
        if (this.model.isNew()) {
          // we must wait until the model is loaded, else bad things happen e.g. the CollectionView automatically updates to show the new event, but we are still displaying the placeholder new event at the top so you see a dupe, AND the new event doesn't have the team set correctly, so it's colours are wrong, and for some reason it just gets added to the top of the list - must be a problem with the date not being set properly and defaulting to 0
          options.wait = true;
          attributes.team_id = ActiveApp.ProfileTeam.get("id");
          ActiveApp.Events.create(attributes, options);
        } else {
          this.model.save({}, options);
        }
      }
    }
  },

  modelSaved: function(model, numEvents) {
    this.savedModels++;
    BFApp.vent.trigger("repeat-event-saved");

    // close the preview event while we render the user's repeat events as they
    // come back from the server
    if (this.savedModels == 1) {
      this.trigger("close:preview");
    }

    if (this.savedModels == numEvents) {
      this.finishedSave(model);
    }
  },

  onRender: function() {
    this.onRenderCommon();
  },

  onShow: function() {
    this.onShowCommon();
    if (!$("html").hasClass("lte9")) {
      sticky(this.$el, $(".new-right-sidebar"));
    }
  }

});
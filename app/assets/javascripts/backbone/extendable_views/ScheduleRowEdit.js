/**
 * This is extended by ScheduleEventEdit on Team page
 * and ScheduleFixtureEdit on League page
 */
BFApp.Views.ScheduleRowEdit = Marionette.ItemView.extend({

  selectedLocation: function() {
    // top (empty) option has value = -1
    if (this.ui.locationsDropdown.val() == "-1") {
      this.model.set("location", null);
    } else {
      var i = parseInt(this.ui.locationsDropdown.val(), 10);
      // i is index, not id as new locations wont yet have IDs
      var loc = this.locations.at(i);
      this.model.set("location", loc);
    }
  },

  toggleLocationMode: function(e) {
    e.preventDefault();
    var isDraggable, toggleLinkText, newLocation;

    this.ui.locationTitle.val("");

    // currently in select mode
    if (this.ui.locationInputGroup.hasClass("hide")) {
      this.ui.locationsDropdown.addClass("hide").val("-1");
      this.ui.locationInputGroup.removeClass("hide");
      toggleLinkText = "Choose previous location";
      isDraggable = true;
      newLocation = new App.Modelss.Location({
        title: ""
      });
    }
    // currently in input mode
    else {
      this.ui.locationInputGroup.addClass("hide");
      this.ui.locationsDropdown.val("-1").removeClass("hide");
      toggleLinkText = "Add new location";
      isDraggable = false;
      newLocation = null;
    }

    this.model.set("location", newLocation);
    this.ui.toggleLocationLink.text(toggleLinkText);
    this.mapView.toggleMarker(isDraggable);
    // reset map
    this.mapView.showDefault();
  },

  showRepeat: function() {
    this.ui.repeatForm.addClass("hide");
    this.ui.repeatButton.removeClass("hide");
    this.changeRepeatCopy();
  },

  hideRepeat: function() {
    this.ui.repeatForm.removeClass("hide");
    this.ui.repeatButton.addClass("hide");
    this.changeRepeatCopy();
  },

  changeRepeatCopy: function() {
    var repeatType = this.ui.repeatType.val();
    var repeatNumber = this.ui.repeatNumber.val();
    var plural = (repeatNumber == "1") ? "" : "s";
    var text = (repeatType == "m") ? "month" : "week";
    this.$(".label-type").text(text + plural);
  },

  syncTitle: function() {
    this.model.set({
      title: this.ui.title.val()
    });
  },

  // when typing in the location field, we just have the title, so set that
  // and the same for the address and wipe any latlng values
  syncLocation: function() {
    var title = this.ui.locationTitle.val();
    this.model.get("location").setFromString(title);
  },

  syncDate: function() {
    // use toCustomISO as we're setting time_local
    this.model.set({
      time_local: this.getDateTime().toCustomISO()
    });
  },

  getDateTime: function() {
    var date = this.ui.date.val(), // e.g. "Wed Jul 17 2013"
      hours = this.ui.hours.val(),
      minutes = this.ui.minutes.val(),
      ampm = this.ui.ampm.val();

    // for fixtures - check if any values are still TBC
    var timeTBC = (hours == -1 || minutes == -1 || ampm == -1);
    this.model.set("time_tbc", timeTBC, {
      silent: true
    });

    if (timeTBC) {
      hours = minutes = 0;
      ampm = "am";
    }

    // put all the fields together and tell moment the format to parse
    var dateTime = date + " " + hours + ":" + minutes + ampm;
    return moment(dateTime, "ddd MMM DD YYYY h:ma");
  },

  setEventStatus: function(status, button) {
    var that = this;

    disableButton(button);

    var attr = {
      status: status
    };

    this.model.save(attr, {
      success: function(model, response, options) {
        // JO 12.07.13 - decided we dont need all this crap,
        // but left it in case others disagree

        //that.render();
        //that.onShow();
        // when cancelling an event, we trigger some things
        //if (status == 1) {
        that.trigger(that.rowType + ":close");
        //that.trigger("schedule:change");
        //}
      },
      error: function() {
        errorHandler({
          button: button
        });
      },
      wait: true
    });
  },

  cancelEvent: function() {
    this.setEventStatus(1, this.ui.cancelButton);
    this.$el.removeClass("edited");
  },

  // uncancel event
  enableEvent: function() {
    this.setEventStatus(0, this.ui.enableButton);
  },

  cancelEdit: function() {
    if (this.model.hasChanges()) {
      this.model.restore();
    }
    this.trigger(this.rowType + ":close");
    return false;
  },

  removeRow: function(msg) {
    if (confirm(msg)) {
      this.trigger(this.rowType + ":close");
      this.model.destroy({
        error: function() {
          errorHandler();
        }
      });
    }
  },

  // disable all form elements except the re-enable button
  // disableInputs: function() {
  //   this.$el.find("input, select, button").not("button[name='re-enable']").prop("disabled", true);
  // },

  onRenderCommon: function() {
    var that = this;
    this.$el.submit(function() {
      return false;
    });

    this.ui.locationSearch.click(function() {
      that.locationSearch();
    });

    // if (this.model.get("status") == 1) {
    //   this.disableInputs();
    // }

    this.syncDate();

    this.mapView = new BFApp.Views.LocationEditMap({
      // NOTE: here we send the event instead of the location obj, this is because the location obj may get replaced by another, so we need a reference to it instead of just the obj itself
      model: this.model,
      locations: this.locations,
      isDraggable: (this.locations.length == 0),
      isEditLocation: true
    });
    this.ui.locationMap.append(this.mapView.render().el);

    this.listenTo(this.mapView, "geocoded:location", function() {
      enableButton(this.ui.locationSearch);
    });

    // make placeholders work in shit browsers
    this.$('input, textarea').placeholder();
  },

  locationSearch: function() {
    var isValid = BFApp.validation.validateInput({
      htmlObject: this.ui.locationTitle,
      require: true,
      requireMessage: false
    });

    if (isValid) {
      disableButton(this.ui.locationSearch);

      this.mapView.performGeocode({
        address: this.ui.locationTitle.val()
      }, false);
    }
  },

  onShowCommon: function() {
    this.initPlugins();
    if (this.model.get("id") == null && !this.ui.title.hasClass("placeholder")) {
      this.ui.title.focus();
    }
  },

  // some plugins cannot be initialised until their containers have been rendered
  initPlugins: function() {
    this.ui.date.glDatePicker({
      hideOnClick: true,
      selectedDate: this.model.getDateObj().toDate(),
      dowOffset: (ActiveApp.CurrentUser.get("country") == "US") ? 0 : 1,
      onClick: (function(el, cell, date, data) {
        el.val(date.toDateString()).change();
      }),
      selectableDateRange: null // override
    });

    this.mapView.showMap();
  },

  // we must pass the model (from the response) around here to get the new
  // location object from the server (with ID, and rounded lat lng numbers).
  // this.model wont work as when creating repeat events, we just do
  // collection.create(attributes)
  finishedSave: function(model) {
    enableButton(this.ui.saveButton);
    this.trigger(this.rowType + ":close");
    this.trigger("schedule:change", true);
    var newLocation = model.get("location");
    if (newLocation && newLocation.isValidWeak() && !this.locations.get(newLocation.get("id"))) {
      this.locations.push(newLocation);
    }
  }

});
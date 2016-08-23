/**
 * Used on the event page for changing the date/time, and also for postpone/reschedule
 * ALSO used on Team page for rescheduling a postponed event
 */
BFApp.Views.ScheduleEditPanel = Marionette.ItemView.extend({

  template: "backbone/templates/panels/event_informations_panel/schedule_edit_panel",

  tagName: "form",

  className: "classic",

  ui: {
    dateInput: "#event-date",
    hoursInput: "#event-time-hour",
    minutesInput: "#event-time-min",
    ampmInput: "#event-time-ampm",
    saveButton: ".save-event",
    dateForm: ".date-form",
    toggle: ".tbc-toggle",
    tbcHint: ".tbc-hint"
  },

  events: {
    "click .save-event": "save",
    "click .close-panel": "closePanel",
    "change .tbc-toggle": "toggleDateForm",
    "change .time-select": "compareDate"
  },

  initialize: function(options) {
    this.model.store();
  },

  toggleDateForm: function() {
    // checked = rescheduling = show cal
    if (this.ui.toggle.prop("checked")) {
      this.ui.dateForm.removeClass("hide");
      this.ui.saveButton.text("Reschedule");
      this.ui.tbcHint.addClass("hide");
      this.initPlugins();
    } else {
      this.ui.dateForm.addClass("hide");
      this.ui.tbcHint.removeClass("hide");
      this.ui.saveButton.prop("disabled", false).text("Postpone");
    }
  },

  compareDate: function() {
    if (!this.ui.toggle.prop("checked") && this.getTimeLocal() == this.model.get("time_local")) {
      this.ui.saveButton.prop("disabled", true);
    } else {
      this.ui.saveButton.prop("disabled", false);
    }
  },


  serializeData: function() {
    var date = this.model.getDateObj();
    var time = date.get12hrTimeObject();

    return {
      eventTime: date.toDateString(),
      hours: time.hours,
      minutes: time.minutes,
      ampm: time.ampm,
      // this decides if we show that postpone/reschedule switch at the top
      postponeMode: this.options.postponeMode,
      rescheduling: this.model.isPostponed()
    };
  },

  closePanel: function() {
    this.model.restore();
    this.trigger("dismiss");
    return false;
  },

  initPlugins: function() {
    var that = this;

    this.ui.dateInput.glDatePicker({
      selectedDate: this.model.getDateObj().toDate(),
      showAlways: true,
      hideOnClick: false,
      dowOffset: (ActiveApp.CurrentUser.get("country") == "US") ? 0 : 1,
      onClick: (function(el, cell, date, data) {
        el.val(date.toDateString());
        that.compareDate();
      })
    }).glDatePicker(true);

    this.compareDate();
    this.ui.dateInput.hide();
  },

  getTimeLocal: function() {
    var date = this.ui.dateInput.val(), // e.g. "Wed Jul 17 2013"
      hours = this.ui.hoursInput.val(),
      minutes = this.ui.minutesInput.val(),
      ampm = this.ui.ampmInput.val();

    // put all the fields together and tell moment the format to parse
    var dateTime = date + " " + hours + ":" + minutes + ampm;
    return moment(dateTime, "ddd MMM DD YYYY h:ma").toCustomISO();
  },

  save: function() {
    var that = this;

    disableButton(this.ui.saveButton);

    var params = {};
    // if we're not in postponeMode (i.e. we're in normal scheduling mode), OR if the toggle is set to reschedule: then we send the date
    if (!this.options.postponeMode || this.ui.toggle.prop("checked")) {
      params.time_local = this.getTimeLocal();
    }

    var options = {
      success: function(model, response, options) {
        that.trigger("dismiss");
      },
      error: function(model, response, options) {
        errorHandler({
          button: that.ui.saveButton
        });
      },
      notify: 1
    };

    if (this.options.postponeMode) {
      // if trying to postpone
      if (!this.ui.toggle.prop("checked")) {
        if (this.model.isPostponed()) {
          this.trigger("dismiss");
        } else {
          this.model.set("status", BFApp.constants.eventStatus.POSTPONED);
          this.model.setStatus(BFApp.constants.eventStatus.POSTPONED, options);
        }
      } else {
        this.model.set("time_local", params.time_local);
        this.model.reSchedule(params.time_local, options);
        this.model.set("status", BFApp.constants.eventStatus.NORMAL);
      }
    } else {
      this.model.save(params, options);
    }
    return false;
  }

});
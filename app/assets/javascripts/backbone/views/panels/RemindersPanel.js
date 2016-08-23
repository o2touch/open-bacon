BFApp.Views.RemindersPanel = Marionette.ItemView.extend({

  template: "backbone/templates/panels/reminders_panel",

  events: {
    'click .send-reminders': 'sendReminders',
    "change .rsvp-toggle": "changeRsvp"
  },

  ui: {
    "sendRemindersButton": ".send-reminders",
    "remindersAction": ".reminders-action",
    "spinner": "span.reminder-spinner"
  },

  /*initialize: function() {
    this.listenTo(this.options.collection, 'change', this.render);
  },

  onShow: function() {
    this.ui.spinner.spin({
      lines: 7,
      width: 2,
      radius: 4,
      length: 0,
      corners: 1,
      color: '#444'
    });

    if (!this.model.get("response_required")) {
      this.$el.parent(".panel-content").addClass("panel-close");
    }
  },*/

  showPanel: function() {
    this.$el.parent(".panel-content").removeClass("panel-close");
  },

  hidePanel: function() {
    this.$el.parent(".panel-content").addClass("panel-close");
  },

  sendReminders: function() {
    var that = this;

    App.Flags.RemindersBeingSent = true;
    disableButton(this.ui.sendRemindersButton);

    App.Event.sendReminders({
      success: function(data) {
        App.Flags.RemindersBeingSent = false;
        enableButton(that.ui.sendRemindersButton);
        that.ui.remindersAction.html("<h4><em>Reminders have been sent to players</em></h4>")
      },
      error: function(model, response) {
        errorHandler();
      },
    });
    return false;
  },

  changeRsvp: function(e) {
    var responseRequired = $(e.currentTarget).prop("checked");
    if (responseRequired) {
      this.showPanel();
    } else {
      this.hidePanel();
    }

    $(e.currentTarget).attr("disabled", "disabled");
    this.ui.spinner.removeClass("hide");
    var that = this;
    this.model.save({
      response_required: $(e.currentTarget).prop("checked")
    }, {
      success: function(model, response, options) {
        $(e.currentTarget).removeAttr("disabled");
        that.ui.spinner.addClass("hide")
      },
      error: function(model, response, options) {
        errorHandler();
        $(e.currentTarget).removeAttr("disabled");
        that.ui.spinner.addClass("hide")
      }
    });
  },


  /*serializeData: function() {
    return {
      awaiting: this.collection.getAwaitingResponse().length,
      responseByDate: this.model.getResponseByDate().getMediumDate(),
      // JACK TODO - uncomment this when BE sends time_of_next_reminder
      nextReminder: null, //prettyDate(this.model.get("time_of_next_reminder")),
      lastReminder: moment(this.model.get("time_of_last_reminder")).fromNow(),
      showButton: this.model.lastReminderOldEnough(),
      response: this.model.get("response_required")
    };
  }*/

});
BFApp.Views.EventActionPanel = Marionette.Layout.extend({

  template: "backbone/templates/panels/event_action_panel",

  regions: {
    "scheduleEditRegion": ".schedule-edit-container",
    "informationEditRegion": ".information-edit-container",
    "locationEditRegion": ".location-edit-container",
    "postponeEditRegion": ".schedule-postpone-container"
  },

  events: {
    "click .cancel-event": "cancelEvent",
    "click .enable-event": "enableEvent",
    "click .edit-event-schedule": "showScheduleEdit",
    "click .edit-event-information": "showInformationEdit",
    "click .edit-event-location": "showLocationEdit",
    "click .postpone-event": "showPostponeEdit",
    // "click .btn-twitter": "twitter",
    // "click .btn-facebook": "facebook",
    // "click .btn-email": "email",
  },

  initialize: function(options) {
    this.listenTo(this.model, "change:status", this.render);
    //this.openInviteLink = "http://" + window.location.host + "/g/" + this.model.get("open_invite_link");
    //this.eventDate = this.model.getMyLocalisedDateObj().format("L");
  },

  serializeData: function() {
    var status = this.model.get("status");
    return {
      // in the future and not cancelled
      isOpen: this.model.isOpen(),
      // show reschedule/cancel options on all events that are not cancelled (inc past events, as this will include events you have postponed, then the date passes, then you want to reschedule)
      showRescheduleButton: (status !== BFApp.constants.eventStatus.CANCELLED),
      // show change date button on all events that are not postponed (as we want them to click reschedule)
      showChangeDateButton: (status !== BFApp.constants.eventStatus.POSTPONED)
    }
  },

  onRender: function() {
    this.informationChangePanelView = new BFApp.Views.PanelLayout({
      panelIcon: "pen",
      panelTitle: "Change details",
      extendClass: "informations-edit popover hide"
    });
    this.informationEditRegion.show(this.informationChangePanelView);


    this.sheduleChangePanelView = new BFApp.Views.PanelLayout({
      panelIcon: "clock",
      panelTitle: "Change date/time",
      extendClass: "re-schedule popover hide"
    });
    this.scheduleEditRegion.show(this.sheduleChangePanelView);

    this.locationChangePanelView = new BFApp.Views.PanelLayout({
      panelIcon: "pin",
      panelTitle: "Change location",
      extendClass: "location-edit popover hide"
    });
    this.locationEditRegion.show(this.locationChangePanelView);

    this.postponeEventPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "calendar",
      panelTitle: "Postpone Event",
      extendClass: "re-schedule popover hide"
    });
    this.postponeEditRegion.show(this.postponeEventPanelView);
  },

  showLocationEdit: function() {
    this.hideScheduleEdit();
    this.hideInformationEdit();
    this.hidePostponeEdit();

    // disable main map
    this.trigger("location:popup", true);

    if (this.locationChangePanelView.$el.hasClass("hide")) {
      this.locationChangePanelView.$el.removeClass("hide");

      var panelContentView = new BFApp.Views.EventLocationEditPanel({
        model: this.model,
      });
      this.locationChangePanelView.showContent(panelContentView)

      this.listenTo(panelContentView, "dismiss", function() {
        this.hideLocationEdit();
        // re-activate main map
        this.trigger("location:popup", false);
      });
    } else {
      this.hideLocationEdit();
    }

    return false;
  },

  hideLocationEdit: function() {
    this.locationChangePanelView.$el.addClass("hide");
    this.trigger("location:popup", false);
    return false;
  },


  showInformationEdit: function() {
    var that = this;

    this.hideScheduleEdit();
    this.hideLocationEdit();
    this.hidePostponeEdit();

    if (this.informationChangePanelView.$el.hasClass("hide")) {
      this.informationChangePanelView.$el.removeClass("hide");
      var panelContentView = new BFApp.Views.EventInformationsEditPanel({
        model: this.model,
      });

      this.informationChangePanelView.showContent(panelContentView)

      panelContentView.on("dismiss", function() {
        that.hideInformationEdit();
      });
    } else {
      this.hideInformationEdit();
    }
    return false;
  },

  hideInformationEdit: function() {
    this.informationChangePanelView.$el.addClass("hide");
    return false;
  },

  showScheduleEdit: function() {
    var that = this;
    this.hideInformationEdit();
    this.hideLocationEdit();
    this.hidePostponeEdit();

    if (this.sheduleChangePanelView.$el.hasClass("hide")) {
      this.sheduleChangePanelView.$el.removeClass("hide");

      var sheduleChangePanelContentView = new BFApp.Views.ScheduleEditPanel({
        model: this.model,
        postponeMode: false
      });

      this.sheduleChangePanelView.showContent(sheduleChangePanelContentView)

      sheduleChangePanelContentView.initPlugins();
      sheduleChangePanelContentView.on("dismiss", function() {
        that.hideScheduleEdit();
      });
    } else {
      this.hideScheduleEdit();
    }
    return false;
  },

  hideScheduleEdit: function() {
    this.sheduleChangePanelView.panelContent.close();
    this.sheduleChangePanelView.$el.addClass("hide");
    return false;
  },


  showPostponeEdit: function() {
    var that = this;

    this.hideInformationEdit();
    this.hideLocationEdit();
    this.hideScheduleEdit();

    if (this.postponeEventPanelView.$el.hasClass("hide")) {
      this.postponeEventPanelView.$el.removeClass("hide");
      var postPoneContentView = new BFApp.Views.ScheduleEditPanel({
        model: this.model,
        postponeMode: true
      });
      this.postponeEventPanelView.showContent(postPoneContentView);

      if (this.model.get("status") == 3) {
        postPoneContentView.initPlugins();
      }

      postPoneContentView.on("dismiss", function() {
        that.hidePostponeEdit();
      });
    } else {
      this.hidePostponeEdit();
    }
    return false;
  },

  hidePostponeEdit: function() {
    this.postponeEventPanelView.panelContent.close();
    this.postponeEventPanelView.$el.addClass("hide");
    return false;
  },



  cancelEvent: function() {
    this.model.cancel();
    return false;
  },

  enableEvent: function() {
    this.model.enable();
    return false;
  },
  // 
  // 
  // facebook: function() {
  //   void(window.open('http://www.facebook.com/share.php?u='.concat(encodeURIComponent(this.openInviteLink)) ));
  //   return false;
  // },
  // 
  // twitter: function() {
  //   void(window.open('http://twitter.com/home/?status='.concat('I just set up a game on ').concat(this.eventDate).concat(', go to ') .concat(encodeURIComponent(this.openInviteLink) .concat(' to RSVP!'))));
  //   return false;
  // },
  // 
  // email: function() {
  //   void(window.open('mailto:?body=Follow the link to RSVP: '.concat(this.openInviteLink).concat('&subject=New game on ').concat(this.eventDate)));
  //   return false;
  // },


});
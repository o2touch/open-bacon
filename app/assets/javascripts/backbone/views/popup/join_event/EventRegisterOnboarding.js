BFApp.Views.EventRegisterOnboarding = Marionette.ItemView.extend({

  template: "backbone/templates/popups/join_event/event_register_onboarding",

  className: 'rfu-onboarding-popup',

  ui: {
    doneButton: "button[name=done]"
  },

  events: {
    "click button[name=done]": "closePopup"
  },

  serializeData: function() {
    var entity, teamName;
    // again we assume that if not on the event page we must be on team page
    if (ActiveApp.Event) {
      var date = ActiveApp.Event.getDateObj();
      entity = ActiveApp.Event.get("title") + " on " + date.getShortDate() + " at " + date.getFormattedTime();
      teamName = ActiveApp.Event.get("team").get("name");
    } else {
      entity = teamName = ActiveApp.ProfileTeam.get("name");
    }
    return {
      entity: entity,
      teamName: teamName
    };
  },

  closePopup: function() {
    disableButton(this.ui.doneButton);
    location.reload();
  }

});
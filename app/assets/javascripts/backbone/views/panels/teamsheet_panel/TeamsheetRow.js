BFApp.Views.TeamsheetRow = Marionette.ItemView.extend({

  tagName: "li",

  template: "backbone/templates/panels/teamsheet_panel/teamsheet_row",

  events: {
    'click .btn-yes': 'markAvailable',
    'click .btn-no': 'markUnavailable'
  },

  serializeData: function() {
    var user = this.model.get("user");
    var isOrganiser = BFApp.rootController.permissionsModel.can("canManageAvailability");

    return {
      userHref: user.getHref(),
      userId: user.get("id"),
      userName: user.get("name"),
      response_status: this.model.get("response_status"),
      htmlPic: user.getPictureHtml("thumb"),
      haveControls: (!this.closedEvent && (isOrganiser || this.model.get("user").get("id") == ActiveApp.CurrentUser.get("id"))),
      isCurrentUser: (this.model.get("user").get("id") == ActiveApp.CurrentUser.get("id")),
      copy: ActiveApp.Tenant.get("general_copy").availability
    };
  },

  /*onBeforeRender: function() {
    var invite_sent = this.model.attributes.invite_sent
    var response_status = this.model.attributes.response_status;
    var text;

    if (response_status == 0) {
      text = "Unavailable";
    } else if (response_status == 1) {
      text = "Available";
    } else if (invite_sent) {
      text = "Awaiting response";
    } else {
      text = "Invite not sent yet";
    }
  },*/

  markAvailable: function() {
    this.model.markAvailable();
    analytics.track('Changed Player Availability', {
      'EventId': ActiveApp.Event.get("id"),
      'AvailabilityStatus': 'available'
    });
    return false;
  },

  markUnavailable: function() {
    this.model.markUnavailable();
    analytics.track('Changed Player Availability', {
      'EventId': ActiveApp.Event.get("id"),
      'AvailabilityStatus': 'unavailable'
    });
    return false;
  }

});
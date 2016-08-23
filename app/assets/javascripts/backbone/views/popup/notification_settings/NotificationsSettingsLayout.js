BFApp.Views.NotificationSettingsLayout = Marionette.Layout.extend({

  template: "backbone/templates/popups/notification_settings/layout",

  className: "notification-settings",

  tagName: "form",

  events: {
    "click button[name='done']": "closePopup"
  },

  regions: {
    content: "#r-notifications-content"
  },

  serializeData: function() {
    return {
      teamName: this.options.team.get("name")
    };
  },

  loadSettings: function() {
    var that = this;

    if (this.options.team.get("settings")) {
      this.showContent();
    } else {
      var spinner = new BFApp.Views.Spinner();
      this.content.show(spinner);

      $.ajax({
        type: "get",
        url: '/api/v1/users/' + ActiveApp.CurrentUser.get("id") + '/notifications/teams/' + this.options.team.get("id"),
        success: function(data) {
          that.options.team.set("settings", data);
          that.showContent();
        },
        error: function(response) {
          that.content.close();
          errorHandler();
        }
      });
    }
  },

  showContent: function() {
    var notificationsView = new BFApp.Views.NotificationView({
      model: this.options.team
    });
    this.content.show(notificationsView);
  },

  closePopup: function() {
    this.trigger("close:popup");
  }

});
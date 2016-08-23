BFApp.Views.NotificationView = Marionette.ItemView.extend({

  template: "backbone/templates/popups/notification_settings/settings",

  className: "notification-settings",

  tagName: "form",

  ui: {
    "switchCheckbox": ".switch-ui-checkbox",
    "regularItems": ".notification-item.regular",
    "unfollowButton": "button[name='unfollow']"
  },

  events: {
    "change @ui.switchCheckbox": "changeSwitch"
  },

  serializeData: function() {
    return {
      settings: this.processSettings(),
      allSetting: {
        name: "notifications_enabled",
        val: this.model.get("settings").notifications_enabled,
        title: "Notifications"
      }
    }
  },

  processSettings: function() {
    var settings = [];
    _.each(this.model.get("settings"), function(val, key) {
      var setting = {
        name: key,
        val: val
      };
      switch (key) {
        case "group_messaging_availability":
          setting.title = "Messages & reminders";
          setting.desc = "Receive team messages and reminders about availability";
          break;
        case "group_team_games":
          setting.title = "Game updates";
          setting.desc = "Receive updates about games, and when game information changes";
          break;
        case "group_team_results":
          setting.title = "Team results";
          setting.desc = "Receive updates about results for this team";
          break;
        case "group_league_results":
          setting.title = "League results";
          setting.desc = "Receive updates about results from other teams in your league";
          break;
        case "group_opposition_info":
          setting.title = "Opposition updates";
          setting.desc = "Receive interesting stats about the opponents in upcoming games";
          break;
        case "group_team_member_updates":
          setting.title = "Team updates";
          setting.desc = "Receive updates about new team members and followers";
          break;
      }
      if (setting.title) {
        settings.push(setting);
      }
    });
    // sort alphabetically for consistency
    return _.sortBy(settings, "name");
  },

  updateCheckboxes: function() {
    var that = this;

    _.each(this.model.get("settings"), function(val, key) {
      that.ui.regularItems.filter("[data-setting='"+key+"']").find(".switch-ui-checkbox").prop("checked", val);
    });
    if (this.model.get("settings").notifications_enabled) {
      this.ui.regularItems.removeClass("disabled");
      this.ui.switchCheckbox.prop("disabled", false);
    }
  },

  changeSwitch: function(e) {
    var that = this;

    var checkbox = $(e.currentTarget);
    var val = checkbox.prop("checked");
    var setting = checkbox.closest(".notification-item").attr("data-setting");
    var settings = {};
    settings[setting] = val;

    // if you set the "notifications_enabled" option to false, then we can update everything
    // now, else wait for server response
    if (setting == "notifications_enabled" && !val) {
      this.ui.switchCheckbox.not(checkbox).prop("checked", false).prop("disabled", true);
      this.ui.regularItems.addClass("disabled");
    }

    $.ajax({
      type: "put",
      url: '/api/v1/users/' + ActiveApp.CurrentUser.get("id") + '/notifications/teams/' + this.model.get("id"),
      data: {
        settings: settings
      },
      success: function(data) {
        that.model.set("settings", data);
        that.updateCheckboxes();
      },
      error: function(response) {
        that.updateCheckboxes();
        errorHandler();
      }
    });
  }

});
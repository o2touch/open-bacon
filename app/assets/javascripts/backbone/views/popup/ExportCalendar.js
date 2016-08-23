BFApp.Views.ExportCalendar = Marionette.ItemView.extend({

  template: "backbone/templates/popups/export_calendar",

  events: {
    'click .close-reveal-modal': 'close',
    'click .url': 'select'
  },

  triggers: {
    "click a.x": "close:popup"
  },

  select: function(e) {
    $(e.currentTarget).select();
  },

  serializeData: function() {
    var url = window.location.host;
    var team = false;

    if (ActiveApp.ProfileTeam !== undefined) {
      team = true;
      url += ActiveApp.ProfileTeam.getHref() + "/events.ics?uuid=" + ActiveApp.ProfileTeam.get("uuid") + "&user=" + ActiveApp.CurrentUser.get("id");
    }

    return {
      data: {
        team: team,
        url: url,
        event: this.model
      }
    };
  },

  onRender: function() {
    if (navigator.appVersion.indexOf("Mac") == -1) {
      this.$el.find(".ical").hide();
    }
  }

});
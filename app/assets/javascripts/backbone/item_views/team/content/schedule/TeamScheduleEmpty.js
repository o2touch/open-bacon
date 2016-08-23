BFApp.Views.TeamScheduleEmpty = Marionette.ItemView.extend({

  template: "backbone/templates/common/content/empty_tab",

  // Use different template for organisers
  organiserTemplate: "backbone/templates/common/content/schedule/schedule_organiser_empty",

  initialize: function(options) {
    this.originalCollection = options.originalCollection;
    if (this.originalCollection.length == 0 && ActiveApp.Permissions.get("canManageTeam") && !ActiveApp.ProfileTeam.get("league")) {
      this.$el.addClass("organiser-empty");
    }
  },

  serializeData: function() {
    var title, msg;

    if (this.originalCollection.length !== 0) {
      title = "No events match your search";
      msg = "";
    } else {
      if (ActiveApp.Permissions.get("canManageTeam") && !ActiveApp.ProfileTeam.get("league")) {
        this.template = this.organiserTemplate;
      } else {
        title = "There are no events in the Schedule";
        msg = "";
      }
    }

    return {
      icon: "calendar",
      title: title,
      msg: msg
    };
  },


});
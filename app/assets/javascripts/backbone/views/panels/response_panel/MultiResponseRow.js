BFApp.Views.ResponseRow = Marionette.ItemView.extend({

  template: "backbone/templates/panels/response_panel/multi_response_row",

  className: "availability",

  events: {
    "click .available": "markAvailable",
    "click .unavailable": "markUnavailable",
    "change .availability-toggle": "availabilityToggle"
  },

  ui: {
    "switchInput": ".availability-toggle"
  },

  initialize: function() {
    this.listenTo(this.model, "change:response_status", this.updateStatus);
  },

  serializeData: function() {
    return {
      pic: this.model.get("user").get("profile_picture_thumb_url"),
      name: this.model.get("user").get("name"),
      status: this.model.get("response_status"),
      currentUser: (this.model.get("user").get("id") == ActiveApp.CurrentUser.get("id")),
      copy: ActiveApp.Tenant.get("general_copy").availability
    };
  },

  updateStatus: function() {
    if (this.ui.switchInput.length == 0) {
      this.render();
      return;
    }

    if (this.model.get("response_status") == 0) {
      this.ui.switchInput.prop("checked", false);
    } else {
      this.ui.switchInput.prop("checked", true);
    }
  },

  availabilityToggle: function(e) {
    if ($(e.currentTarget).prop("checked") === true) {
      this.markAvailable();
    } else {
      this.markUnavailable();
    }
  },

  markUnavailable: function() {
    if (App.pageType == "open-invite") {
      this.trigger('button-unavailable:clicked');
    } else {
      if (this.model.get("response_status") !== 0) {
        this.model.markUnavailable();
      }
      this.$el.addClass("unavailable");
    }
  },

  markAvailable: function() {
    if (App.pageType == "open-invite") {
      this.trigger('button-available:clicked');
    } else {
      if (this.model.get("response_status") !== 1) {
        this.model.markAvailable();
      }
      this.$el.addClass("available");

    }
  }

});
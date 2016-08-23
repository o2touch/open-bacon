var App = {
  Views: {
    EventSetup: {}
  },
  Collections: {},
  Modelss: {},
  Routers: {},
  Permissions: {},

  // list of flags that can be set to eg. stop things being sent multiple times
  Flags: {
    RemindersBeingSent: false
  },

  showView: function(view, options) {

    this.options = _.extend(this.defaults, options)

    if (this.currentView) {
      this.currentView.close();
      delete this.currentPopover;
    }
    this.currentView = view;

    $(this.options.region).html(this.currentView.render().el);
  },
  
  /* Those function (showpopover & closepopover) are not use any where on the website */
  showPopover: function(view) {
    if (this.currentPopover) {
      this.currentPopover.close();
    }
    this.currentPopover = view;

    $("#popover").html(this.currentPopover.render().el);
  },

  closePopover: function() {
    if (this.currentPopover) {
      this.currentPopover.close();
      delete this.currentPopover;
    }
    $("#popover").html("");
  }
};
App.vent = Backbone.Events
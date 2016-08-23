BFApp.Views.PopupLayout = Marionette.Layout.extend({

  template: "backbone/templates/popups/popup_layout",

  className: "popup-layout",

  regions: {
    content: "#popup-content",
    popupContent: ".popup-content"
  },

  ui: {
    closeButton: "[name=x]"
  },

  triggers: {
    "click [name=x]": "close:popup"
  },

  events: {
    "click .grey-overlay": "clickedOverlay"
  },

  initialize: function() {
    if (this.options.animation) {
      this.$el.css({
        "opacity": "0"
      });
    }
  },

  serializeData: function() {
    return {
      showCloseButton: this.options.allowClosePopup,
      popupClass: this.options.popupClass
    };
  },

  onRender: function() {
    if (this.options.animation) {
      this.$el.animate({
        "opacity": "1"
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
    }
  },

  clickedOverlay: function() {
    if (this.options.allowClosePopup) {
      this.trigger("close:popup");
    }
  }

});
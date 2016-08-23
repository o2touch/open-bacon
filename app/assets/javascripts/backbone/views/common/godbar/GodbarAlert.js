BFApp.Views.GodbarAlert = Marionette.ItemView.extend({
  className: "text-center",
  template: "backbone/templates/common/godbar/godbar_alert",

  initialize: function() {
    this.$el.addClass(this.options.type);
  },

  serializeData: function() {
    return {
      message: this.options.message,
      icon: this.options.icon,
      explanation: this.options.explanation
    };
  }


});
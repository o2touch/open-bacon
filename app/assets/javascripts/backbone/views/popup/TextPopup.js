BFApp.Views.TextPopup = Marionette.ItemView.extend({

  template: 'backbone/templates/popups/text_popup',

  className: "text-popup text-center confirmation-popup",

  serializeData: function() {
    return {
      icon: this.options.icon,
      title: this.options.title,
      msg: this.options.msg
    }
  }

});
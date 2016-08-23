BFApp.Views.Spinner = Marionette.ItemView.extend({

  template: "backbone/templates/common/content/spinner",

  className: "spinner-loading",

  ui: {
    "spinner": ".spinner"
  },

  onShow: function() {
    this.ui.spinner.spin({
      width: 4,
      radius: 20,
      corners: 1,
      lines: 10,
      color: '#555',
      top: 'auto',
      left: 'auto'
    });

    if (this.options.size == "medium") {
      this.ui.spinner.spin({
        width: 3,
        radius: 7,
        corners: 1,
        lines: 8,
        color: '#555',
        top: 'auto',
        left: 'auto'
      });
    }
  }

});
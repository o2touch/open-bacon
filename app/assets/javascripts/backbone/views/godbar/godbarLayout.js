BFApp.Views.GodbarLayout = Marionette.Layout.extend({

  template: "backbone/templates/godbar/godbar_layout",

  regions: {
    godbarContent: "#godbar-content"
  },

  className: "godbar-new",

  initialize: function(options) {
    this.options = options;
  },

  onRender: function() {
    if (!_.isUndefined(this.options.godbarClass)) this.$el.addClass(this.options.godbarClass);
  },

  onShow: function()  {
    if (!_.isUndefined(this.options.view)) this.godbarContent.show(this.options.view);
  },



});
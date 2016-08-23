BFApp.Views.PanelLayout = Marionette.Layout.extend({

  template: "backbone/templates/panels/panel_layout",
  tagName: "div",
  className: "panel",

  regions: {
    "panelContent": ".panel-content"
  },

  onShow: function() {
    this.showLoading();
  },

  showLoading: function() {
    var spinner = new BFApp.Views.Spinner({size: "medium"});
    this.panelContent.show(spinner);
    this.$el.addClass("panel-loading");
  },

  showContent: function(view) {
    this.panelContent.show(view);
    this.$el.removeClass("panel-loading");
  },

  serializeData: function() {
    if (this.options.extendClass) {
      this.$el.addClass(this.options.extendClass);
    }
    return {
      icon: (this.options.panelIcon) ? this.options.panelIcon : false,
      title: (this.options.panelTitle) ? this.options.panelTitle : false,
      panelTips: (this.options.panelTips) ? this.options.panelTips : false
    };
  }

});
BFApp.Views.AdminLayout = Marionette.Layout.extend({
  
  className: "admin-page",
  template: "backbone/templates/admin/admin_layout",

  regions: {
    mapView: "#r-map",
    gamecard: "#r-gamecard",
    sidebar: "#r-sidebar",
    systemPrompt: "#r-system-prompt",
    content: "#r-event-content",
    eventPopover: "#r-event-edit",
  }

});
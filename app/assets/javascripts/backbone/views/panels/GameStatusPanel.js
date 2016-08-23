BFApp.Views.GameStatus = Marionette.ItemView.extend({

  template: "backbone/templates/panels/game_status_panel",

  events: {
    "click .enable-event": "enableEvent",
  },
  
  triggers:{
    "click .reschedule-event": "re-schedule:clicked"
  },

  enableEvent: function() {
    this.model.enable();
  },

  initialize: function() {
    this.listenTo(this.model, "change", _.bind(this.render, this));
  },
  
  serializeData: function() {
    return {
      gameStatus: this.model.get("status"),
      canEdit: BFApp.rootController.permissionsModel.can("canEditEvent")
    };
  }

});
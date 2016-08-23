BFApp.Views.ActivityIndicator = Marionette.ItemView.extend({
  
  template: "backbone/templates/common/activity_indicator",
  className:"activity-indicator",

  triggers: {
    "click .edit-details": "edit-details-button:clicked" 
  },

  startClose: function(){
    var that = this;
    this.$el.fadeOut(function(){
      that.close();
    });
  }
  
});

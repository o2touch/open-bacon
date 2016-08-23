BFApp.Views.FaftFollowPanel = Marionette.ItemView.extend({

  template: "backbone/templates/faft/panel/faft_follow_panel",
  
  onRender: function(){
    var followForm = new BFApp.Views.FollowTeamForm(window.followFormOptions);
    this.$("#follow-form-container").append(followForm.render().el);
  }
  
});
BFApp.Views.FollowTeamPopupExit = BFApp.Views.FollowTeamPopup.extend({
  
  customSerializeData: function(data) {
    data.title = "Get mobile updates about your team's latest games, results & league position";
    data.msg = "Follow your team below";
    data.closeCopy = "No, I wouldn't like to follow right now, but may come back in the future";
  },

  onShow: function() {
    this.$el.addClass("marketing-popup");

    var teamForm = new BFApp.Views.FollowTeamFormExit(this.options);
    this.formRegion.show(teamForm);
    
    analytics.track('Viewed Leaving Popup');
  },

});
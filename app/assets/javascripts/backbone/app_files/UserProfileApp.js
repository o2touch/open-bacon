var UserProfileApp = _.extend({}, AppBase, {

  type: AppTypes.UserProfile,

  showFBConnect: function() {
    // nope.
  },

  loginFB: function() {
    // nope.
  },

  fbOnLoad: function() {
    ProfileApp.showFBConnect();
  },

  showView: function(view) {
    //console.log('START OF SV UP');
    if (this.currentView) {
      this.currentView.close();
    }
    this.currentView = view;
    $(".content").html(this.currentView.render().el);
  },

  init: function() {
    //this.Teammates = new App.Collections.PlayersCollection();
  }
});

App.vent = Backbone.Events;
/*var UserProfileApp = _.extend({}, AppBase, {

  type: AppTypes.UserProfile,

  showFBConnect: function() {
    FB.getLoginStatus(function(response) {
      if (response.status === 'connected') {
        var uid = response.authResponse.userID;
        var accessToken = response.authResponse.accessToken;
      } else if (response.status === 'not_authorized') {
        $("#onboarding-panel").append("<a href='javascript:ProfileApp.loginFB()'>Connect Facebook</a>");

      } else {}
    });
  },

  loginFB: function() {
    FB.login(function(response) {
      if (response.session) {
        location.href = '/users/auth/facebook';
      } else {}
    });
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
});*/

App.vent = Backbone.Events;
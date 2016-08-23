BFApp.Views.PaywallFacebookShare = Marionette.ItemView.extend({

  template: "backbone/templates/popups/paywall_facebook_share",

  className: "paywall-popup-flow-facebook-share",

  ui: {
    "facebookButton": "button[name='facebook']"
  },

  events: {
    "click @ui.facebookButton": "facebookLogin",
    "click .skip": "skip"
  },

  onShow: function() {
    analytics.track("Viewed FAFT Team Paywall Share", {});
  },

  facebookFail: function() {
    enableButton(this.ui.facebookButton);
  },

  facebookLogin: function() {
    var that = this;
    disableButton(this.ui.facebookButton);

    //console.log("calling login");
    FB.login(function(response) {
      //console.log("Login response: "+JSON.stringify(response));
      if (response.authResponse) {
        //alert('login success got auth token = '+response.authResponse.accessToken);
        that.getFriends();
      } else {
        //alert('login failed');
        that.facebookFail();
      }
    }, {
      // location gives us their country
      // activities and interests are self-explanitory
      // likes gives us their "sports" field
      scope: 'friends_location,friends_activities,friends_interests,friends_likes'
    });
  },

  getFriends: function() {
    var that = this,
      limit = 30;

    /**
     * Thoughts:
     * 1. Removed family filter - keep more specific - to potential team mates etc.
     * Means marketing copy can be more specific as well, and less perms to ask for.
     * 2. Removed age filter - anyone who likes football and is your friend is going to
     * be between 13-50 anyway, also less perms to ask for
     * 3. Filter by your own sex in order to try and catch your teammates
     * 4. Football filters: either if it's in your activities, interests, or sports (likes)
     */

    // see https://developers.facebook.com/docs/reference/fql
    FB.api({
      method: 'fql.query',
      query: "SELECT uid FROM user " +
        "WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) " +
        "AND current_location.country = 'United Kingdom' " +
        "AND sex IN (SELECT sex FROM user WHERE uid = me()) " +
        "AND (" +
        "strpos(lower(interests),'football') >= 0 " +
        "OR strpos(lower(activities),'football') >= 0 " +
        "OR 'Football' IN sports.name " +
        "OR 'Association football' IN sports.name " +
        ") " +
        "LIMIT " + limit
    }, function(response) {
      //console.log(response);
      if (!response.error_code) {
        var uids = _.pluck(response, "uid");
        that.showRequestDialog(uids);
      } else {
        that.facebookFail();
      }
    });
  },

  showRequestDialog: function(uids) {
    var that = this;

    FB.ui({
      method: 'apprequests',
      message: 'Check out Mitoo!',
      to: uids //[100008000529005] // cuthbert
    }, function(response) {
      //console.log(response);
      if (!response.error_code) {
        analytics.track("Sent facebook requests to friends", analyticsObject);
        that.done();
      } else {
        that.facebookFail();
      }
    });
  },

  skip: function(e) {
    e.preventDefault();
    this.done();
  },

  done: function() {
    BFApp.vent.trigger("paywall-flow:next", {
      downloadStage: true
    });
  }

});
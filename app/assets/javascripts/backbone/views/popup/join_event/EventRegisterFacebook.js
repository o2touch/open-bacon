BFApp.Views.EventRegisterFacebook = Marionette.Layout.extend({

  template: "backbone/templates/popups/join_event/event_register_facebook",

  regions: {
    eventRow: "#er-event-row"
  },

  ui: {
    emailInput: "input[name=email]",
    locationGroup: "#er-location-group",
    facebookButton: "button[name=facebook]",
    signupButton: "button[name=signup]"
  },

  events: {
    "submit form": "emailSignup",
    "click button[name=facebook]": "facebookSignup",
    "click a[name=login]": "showLogin",
    "click a[name=cancel]": "closePopup"
  },

  onRender: function() {
    var location = ActiveApp.Event.get("location");
    BFApp.renderTemplate(this.ui.locationGroup, "map_search/event_location_group", {
      locationNumber: "1",
      addressTitle: location.get("title"),
      distance: false,
      markerIcon: getMapPinIcon("o2_touch", "pin1")
    });

    var eventView = new BFApp.Views.WidgetEventRow({
      model: ActiveApp.Event,
      hideJoin: true
    });
    this.eventRow.show(eventView);
  },

  emailSignup: function(e) {
    e.preventDefault();
    var that = this;

    var isEmail = BFApp.validation.isEmail({
      htmlObject: this.ui.emailInput
    });

    if (isEmail) {
      disableButton(this.ui.signupButton);
      // wait a second (pretend we're loading) as it seems weird/fake to immediately jump to the next stage
      setTimeout(function() {
        that.triggerNext({
          email: that.ui.emailInput.val()
        });
      }, 500);
    }
  },

  facebookSignup: function() {
    var that = this;
    disableButton(this.ui.facebookButton);

    FB.getLoginStatus(function(response) {
      if (response.status === 'connected') {
        that.facebookLoad(response.authResponse.accessToken);
      } else {
        FB.login(function(response) {
          if (response.authResponse) {
            that.facebookLoad(response.authResponse.accessToken);
          } else {
            that.facebookFail();
          }
        }, {
          // extra perms to help fill out the register form next
          scope: 'email,user_birthday'
        });
      }
    });
  },

  facebookFail: function() {
    enableButton(this.ui.facebookButton);
  },

  facebookLoad: function(token) {
    var that = this;

    // load the appropriate deets, then trigger next with those values attached
    FB.api({
      method: 'fql.query',
      query: "SELECT uid,name,email,birthday_date,sex FROM user WHERE uid = me()"
    }, function(response) {
      //console.log(response);
      if (!response.error_code) {
        var dob = "";
        if (response[0].birthday_date) {
          var dateParts = response[0].birthday_date.split("/");
          // YYYY-MM-DD
          dob = dateParts[2] + "-" + dateParts[0] + "-" + dateParts[1];
        }
        var gender = "";
        if (response[0].sex) {
          gender = response[0].sex.charAt(0);
        }
        that.triggerNext({
          name: response[0].name,
          email: response[0].email,
          dob: dob,
          gender: gender,
          authorization: {
            uid: response[0].uid,
            token: token
          }
        });
      } else {
        that.facebookFail();
      }
    });
  },

  triggerNext: function(attrs) {
    var user = new App.Modelss.User(attrs);
    this.trigger("next", user);
  },

  showLogin: function(e) {
    e.preventDefault();
    BFApp.vent.trigger("login-popup:show");
  },

  closePopup: function() {
    BFApp.vent.trigger("popup:close");
  },

  /*next: function() {
    this.triggerNext({});
  }*/

});
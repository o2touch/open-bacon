/* BFApp Controller - This is the main "controller" of controllers */
BFApp.Controllers.App = Marionette.Controller.extend({

  activityIndicatorView: null,
  waitingOnActivity: 0,
  permissionsModel: null,

  initialize: function(options) {
    this.options = options;

    BFApp.vent.on("activity:started", _.bind(this.showActivityIndicator, this));
    BFApp.vent.on("activity:ended", _.bind(this.hideActivityIndicator, this));
  },

  registerCurrentPermissions: function(permissionsModel) {
    this.permissionsModel = permissionsModel;
  },

  start: function() {
    /* Navigation View */
    var naviView = new BFApp.Views.NaviView();
    BFApp.navi.show(naviView);

    // don't show footer on homepage
    if (ActiveApp.page != "home") {
      var footer = new BFApp.Views.Footer();
      BFApp.footer.show(footer);
    }
  },


  showSignupReminder: function() {
    var playerSignupReminderView = new BFApp.Views.PlayerSignupReminder({
      model: ActiveApp.CurrentUser
    });

    BFApp.vent.trigger("show:godbar", {
      view: playerSignupReminderView,
      godbarClass: "warning fixed"
    });
  },

  startEventModule: function(options) {
    BFApp.module("Event").start(options);
  },

  startUserProfileModule: function(options) {
    if (_.isUndefined(options) || options === "") {
      return;
    }

    BFApp.module("UserProfile").start(options);
  },

  startTeamProfileModule: function(options) {
    BFApp.module("TeamProfile").start(options);
  },

  startPopupModule: function(options) {
    BFApp.module("Popup").start(options);
  },

  startPrivateProfileModule: function(options) {
    BFApp.module("PrivateProfile").start(options);
  },

  startLeagueProfileModule: function(options) {
    BFApp.module("LeagueProfile").start(options);
  },

  showActivityIndicator: function() {
    this.activityIndicatorView = new BFApp.Views.ActivityIndicator({});
    BFApp.activityIndicator.show(this.activityIndicatorView);
    this.waitingOnActivity++;
  },

  hideActivityIndicator: function() {
    this.waitingOnActivity--;
    if (this.waitingOnActivity === 0) {
      this.activityIndicatorView.startClose();
    }
  }

});
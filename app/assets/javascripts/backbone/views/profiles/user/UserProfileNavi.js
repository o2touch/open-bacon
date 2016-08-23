BFApp.Views.UserProfileNavi = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/user/navi",
  className: "content-navi",
  tagName: "ul",

  initialize: function(options) {
    var that = this;
    BFApp.UserProfile.router.bind('route', function(route) {
      that.onNavigationChange(route);
    });
  },

  onNavigationChange: function(route) {
    if (route == "defaultRoute") return;

    var tab = route.replace('show', '').toLowerCase();

    //Hack for edit detail redirect from email
    if (tab == "editdetails") tab = "activity";
    var navEl = this.$el.find("#nav-" + tab);

    if (!navEl.hasClass('selected')) {
      this.$el.find('li.selected').removeClass('selected');
      navEl.addClass('selected');
    }
  },

  serializeData: function() {
    return {
      id: ActiveApp.ProfileUser.get("id"),
      showSchedule: (ActiveApp.Permissions.get("canViewProfileSchedule") && ActiveApp.CurrentUser.isLoggedIn())
    };
  }

});
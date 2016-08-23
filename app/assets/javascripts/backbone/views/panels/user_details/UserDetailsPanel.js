BFApp.Views.UserDetailsPanel = Marionette.Layout.extend({

  template: "backbone/templates/panels/user_details/user_details_panel",

  tagName: "div",

  className: "panel user-profile",

  events: {
    "click .fb-button": "loginToFB"
  },

  regions: {
    "editRegion": ".edit-user-profile-region"
  },

  modelChanged: function() {
    this.render();
  },

  initialize: function() {
    if (ActiveApp.CurrentUser.get("id") == this.model.get("id")) {
      this.listenTo(ActiveApp.CurrentUser, "change", this.render);
    }
  },

  serializeData: function() {
    var isMyChildren = false;
    var parents;
    if (ActiveApp.ProfileUserParents) {
      isMyChildren = ActiveApp.ProfileUserParents.get("id") == ActiveApp.CurrentUser.get("id");
      parents = ActiveApp.ProfileUserParents;
    }

    return {
      htmlPic: this.model.getPictureHtml("small"),
      currentUserIsSelf: this.model.get("id") == ActiveApp.CurrentUser.get("id"),
      userName: this.model.get("name"),
      userFBConnected: this.model.get("name"),
      userBio: this.model.get("bio"),
      userCanReadDetails: ActiveApp.Permissions.get("canReadDetails"),
      userEmail: this.model.get("email"),
      userMobile: this.model.get("mobile_number"),
      isJunior: this.model.get("junior"),
      isMyChildren: isMyChildren,
      parents: parents,
      fbConnect: this.options.showFacebookButton
    };
  },

  loginToFB: function() {
    analytics.track('Clicked Connect facebook', {});
    url = '/users/auth/facebook/callback.json';
    window.location.href = url; // We should really do this using an Ajax request (below)
  }

});
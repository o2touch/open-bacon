BFApp.Views.UserProfileLayout = Marionette.Layout.extend({

  className: "user-page",

  template: "backbone/templates/profiles/user/user_layout",

  regions: {
    contentNavi: ".content-navi-container",
    content: ".primary-content",
    userProfile: "#r-user-profile",
    childrenPanel: "#r-children-panel",
    teamsPanel: "#r-team-panel",
    friendsPanel: "#r-friend-panel"
  },

  initTeamPanel: function() {
    this.teamPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "badge",
      panelTitle: "Teams",
      extendClass: "teams"
    });
    this.teamsPanel.show(this.teamPanelView);
  },

  initFriendsPanel: function() {
    this.friendsPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "users",
      panelTitle: "Friends",
      extendClass: "friends"
    });
    this.friendsPanel.show(this.friendsPanelView);
  },

  initChildrenPanel: function() {
    this.childrenPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "users",
      panelTitle: "Children",
      extendClass: "children",
      panelTips: {
        text: "Children's profiles are not public.",
        link: {
          url: "http://j.mp/14tgdSt",
          short: "What does this mean?"
        }
      }
    });
    this.childrenPanel.show(this.childrenPanelView);
  }

});
BFApp.Views.FaftRightSidebarLayout = Marionette.Layout.extend({

  className: "faft-right-sidebar-layout",

  template: "backbone/templates/faft/layout/faft_right_sidebar_layout",

  regions: {
    clubPanel: "#club-panel",
    marketingCopy: "#marketing-copy",
    followPrimaryRegion: "#follow-team-panel",
    followSecondaryRegion: "#follow-team-panel-secondary",
    downloadTheAppRegion: "#download-the-app",
    goalsRegion: "#goals-widget",
    emailRegion: "#email-club"
  },

  initClubPanel: function() {
    var panelLayout = new BFApp.Views.PanelLayout({
      panelTitle: "Club",
      extendClass: "club-information-panel"
    });
    this.clubPanel.show(panelLayout);
    return panelLayout;
  },

  initMarketingCopyPanel: function() {
    var panelLayout = new BFApp.Views.PanelLayout();
    this.marketingCopy.show(panelLayout);
    return panelLayout;
  }

});
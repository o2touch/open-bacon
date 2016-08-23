BFApp.Views.TeamProfileLayout = Marionette.Layout.extend({

  className: "team-page",

  template: "backbone/templates/profiles/team/team_layout",

  regions: {
    header: "#team-profile",
    contentNavi: ".content-navi-container",
    content: "#r-team-content",
    goals: "#r-goals",
    notice: "#r-sidebar-notice",
    squadInformation: "#r-squad-information",
    nextGame: "#r-next-game",
    teammates: "#r-team-mates",
    scheduleEdit: "#r-edit-schedule-help",
    downloadApp: "#r-download-app",
    tenantSpecific: "#r-tenant-specific"
  },

  initialize: function() {
    var league = ActiveApp.ProfileTeam.get("league");
    if (league) {
      this.$el.addClass("league-" + league.get("slug").toLowerCase());
    }

    var that = this;
    this.scheduleEdit.on("show", function() {
      that.teammates.close();
      that.nextGame.close();
      that.goals.close();
      that.downloadApp.close();
      that.tenantSpecific.close();
      that.$(".body").addClass("open");
    }).on("close", function() {
      that.$(".body").removeClass("open");
      that.showAppLink();
    });
  },

  showAppLink: function() {
    if (!ActiveApp.FaftFollowTeam.showDownloadLinks) return;
    var downloadAppView = new BFApp.Views.DownloadApp();
    this.downloadApp.show(downloadAppView);
  },

  onShow: function() {
    this.initTeammatesPanel();
    this.showAppLink();
  },

  initScheduleHelpTextPanel: function() {
    this.scheduleHelpTextPanel = new BFApp.Views.PanelLayout({
      panelIcon: "pen",
      panelTitle: "Edit schedule",
      extendClass: "edit-results-onboarding"
    });

    this.scheduleEdit.show(this.scheduleHelpTextPanel);
  },

  initTeammatesPanel: function() {
    this.teammatesPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "users",
      panelTitle: "Players in Team",
      extendClass: "teammates",
      panelTips: {
        text: "All players receive notifications about schedule updates and can track their availability.",
      }
    });

    this.teammates.show(this.teammatesPanelView);
  },

  initGameActivityPanel: function() {
    this.gameActivityPanelView = new BFApp.Views.PanelLayout({
      panelIcon: "star",
      panelTitle: "Event Activity",
      extendClass: "event-activity",
    });

    this.nextGame.show(this.gameActivityPanelView);
  },

  showO2TouchLinksPanel: function() {
    var layout = new BFApp.Views.PanelLayout({
      panelTitle: "Links"
    });
    this.tenantSpecific.show(layout);

    var view = new BFApp.Views.O2TouchTeamLinksPanel();
    layout.showContent(view);
  }

});
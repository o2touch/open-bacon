describe("BFApp.Views.DownloadAppPopup", function() {

  var view, teamName = "Some Team";

  describe("rendering view", function() {

    beforeEach(function() {
      window.ActiveApp = {
        FaftFollowTeam: {}
      };
      view = new BFApp.Views.DownloadAppPopup({
        actionType: "followed",
        teamName: teamName
      });
      view.render();
    });

    afterEach(function() {
      delete window.ActiveApp;
      view = null;
    });

    it("displays the popup", function() {
      expect(view.$el.find("h1")).toContainText(teamName);
    });

  });

});
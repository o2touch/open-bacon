describe("BFApp.Views.TeamPanel", function() {

  beforeEach(function() {
    this.view = new BFApp.Views.TeamPanel();
  });

  describe("rendering", function() {

    beforeEach(function() {

      ActiveApp = UserProfileApp;

      this.teamsListView = new Marionette.View();
      this.teamsListViewStub = sinon.stub(BFApp.Views, "TeamsList").returns(this.teamsListView);

      this.team1 = new App.Modelss.Team({
        id: 1
      })
      this.team2 = new App.Modelss.Team({
        id: 2
      })

      this.view.collection = new Backbone.Collection([
        this.team1,
        this.team2
      ]);

      this.view.onShow();

    });

    afterEach(function() {
      delete ActiveApp;
    });

    it("should create a TeamList view for the collection", function() {
      expect(this.teamsListViewStub).toHaveBeenCalledOnce();
      expect(this.teamsListViewStub).toHaveBeenCalledWith({
        collection: this.view.collection
      });
    });

  });

});
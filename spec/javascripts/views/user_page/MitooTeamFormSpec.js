describe("BFApp.Views.MitooTeamForm", function() {

  var teamFormView;
  var teamModel;


  describe("new team", function() {

    beforeEach(function() {
      teamModel = new App.Modelss.Team();

      teamFormView = new BFApp.Views.MitooTeamForm({
        model: teamModel,
        type: "new"
      });
    });


    it("Display and empty team form", function() {
      teamFormView.render();
      expect(teamFormView.$el.find("#team-name").val()).toEqual("");
      expect(teamFormView.$el.find("#team-sport").val()).toEqual("Athletics");
      expect(teamFormView.$el.find("input[name='age_group']:checked").val()).toEqual("99");
    });

    it("Doesn't display league/badge fields", function() {
      teamFormView.render();
      expect(teamFormView.$el.find(".pfl-pic-section").length).toEqual(0);
      expect(teamFormView.$el.find("#league-name").length).toEqual(0);
    });

  });



  describe("edit team", function() {

    beforeEach(function() {
      teamModel = new App.Modelss.Team({
        age_group: "14",
        colour1: "FAB800",
        colour2: "2ABD7A",
        league_name: "Bluefields",
        name: "Real Santa Monica Lions",
        sport: "Softball",
        profile_picture_small_url: "/somepath/to/picture.png"
      });


      teamFormView = new BFApp.Views.MitooTeamForm({
        model: teamModel,
        type: "edit"
      });
    });

    it("Display the correct information", function() {
      teamFormView.render();

      expect(teamFormView.$el.find("#team-name").val()).toEqual(teamModel.get("name"));
      expect(teamFormView.$el.find("#team-sport").val()).toEqual(teamModel.get("sport"));
      expect(teamFormView.$el.find("input[name='age_group']:checked").val()).toEqual(teamModel.get("age_group"));
      expect(teamFormView.$el.find("input[name=primary]:checked").val()).toEqual(teamModel.get("colour1"));
      expect(teamFormView.$el.find("input[name=secondary]:checked").val()).toEqual(teamModel.get("colour2"));
      expect(teamFormView.$el.find("img.circle").prop("src")).toEqual(window.location.origin + teamModel.get("profile_picture_small_url"));
    });

    it("initialize the bind picture uploader function & Initialize the form", function() {
      var initFormSpy = sinon.spy(teamFormView, "formInit");
      var bindPictureUploaderSpy = sinon.spy(teamFormView, "bindPictureUploader");

      teamFormView.render();

      expect(initFormSpy).toHaveBeenCalledOnce();
      expect(bindPictureUploaderSpy).toHaveBeenCalledOnce();
    });

    it("Don't display the league fields if the team is part of a league", function() {
      teamModel.set("league", new App.Modelss.League());

      teamFormView.render();

      expect(teamFormView.$el.find("#league-name").length).toEqual(0);
    });

  });



  describe("save team", function() {

    beforeEach(function() {
      teamModel = new App.Modelss.Team();

      teamFormView = new BFApp.Views.MitooTeamForm({
        model: teamModel,
        type: "new"
      });

      spyOn(teamModel, "validateSave").andCallThrough();

      teamFormView.render();
      teamFormView.$el.submit();
    });

    it("trigger a model validation when submit", function() {
      expect(teamModel.validateSave).toHaveBeenCalled();
    });

  });

});
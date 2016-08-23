describe("BFApp.Views.SquadForm", function() {

  var newPlayer;
  var addPlayerform;

  beforeEach(function() {
    newPlayer = new App.Modelss.User();

    window.ActiveApp = {
      ProfileTeam: new App.Modelss.Team()
    };
  });

  describe("for an adult team", function() {

    beforeEach(function() {
      ActiveApp.ProfileTeam.set("age_group", 99);
      addPlayerform = new BFApp.Views.SquadForm({
        model: newPlayer
      });
      addPlayerform.render();
    });

    it("displays the correct form", function() {
      expect(addPlayerform.$el.find(".parent-details-collapsible").length).toEqual(0);
      expect(addPlayerform.$el.find("label[for='player-name']").text()).toEqual("Player's name");
    });

    it("submitting the form makes the right request", function() {
      spyOn($, "ajax");

      var name = "yolo";
      var email = "swag@lol.xD";
      addPlayerform.$el.find("input[name='player-name']").val(name);
      addPlayerform.$el.find("input[name='email']").val(email);
      addPlayerform.$el.submit();

      var request = $.ajax.mostRecentCall.args[0];
      var data = JSON.parse(request.data);

      expect(request.type).toEqual("POST");
      expect(request.url).toEqual("/api/v1/users/invitations?team_id=undefined&save_type=TEAMPROFILE");
      expect(data.user.name).toBe(name);
      expect(data.user.email).toBe(email);
    });
  });



  describe("for a junior team", function() {

    beforeEach(function() {
      ActiveApp.ProfileTeam.set("age_group", 9);
      addPlayerform = new BFApp.Views.SquadForm({
        model: newPlayer
      });
      addPlayerform.render();
    });

    it("displays the correct form", function() {
      expect(addPlayerform.$el.find(".parent-details-collapsible").length).toEqual(1);
      expect(addPlayerform.$el.find("label[for='player-name']").text()).toEqual("Junior's name");
    });

    it("submitting the form makes the right request", function() {
      spyOn($, "ajax");

      var juniorName = "yolo's son";
      var parentName = "yolo";
      var parentEmail = "swag@lol.xD";

      addPlayerform.$el.find("input[name='player-name']").val(juniorName);
      addPlayerform.$el.find("input[name='parent-name']").val(parentName);
      addPlayerform.$el.find("input[name='parent-email']").val(parentEmail);
      addPlayerform.$el.submit();

      var request = $.ajax.mostRecentCall.args[0];
      var data = JSON.parse(request.data);

      expect(request.type).toEqual("POST");
      expect(request.url).toEqual("/api/v1/users/invitations?team_id=undefined&save_type=JUNIOR");
      expect(data.user.name).toBe(juniorName);
      expect(data.user.parent_name).toBe(parentName);
      expect(data.user.email).toBe(parentEmail);
    });

  });

  describe("for a junior team, adding a second parent", function() {

    beforeEach(function() {
      ActiveApp.ProfileTeam.set("age_group", 9);
      addPlayerform = new BFApp.Views.SquadForm({
        model: newPlayer,
        secondParent: true
      });
      addPlayerform.render();
    });

    it("displays the correct form", function() {
      expect(addPlayerform.$el.find("input[name='player-name']").prop("disabled")).toBe(true);
      expect(addPlayerform.$el.find(".parent-details-collapsible").length).toEqual(1);
      expect(addPlayerform.$el.find("label[for='player-name']").text()).toEqual("Junior's name");
    });

    it("submitting the form makes the right request", function() {
      spyOn($, "ajax");

      var juniorName = "yolo's son";
      var parentName = "yolo";
      var parentEmail = "swag@lol.xD";

      addPlayerform.$el.find("input[name='player-name']").val(juniorName);
      addPlayerform.$el.find("input[name='parent-name']").val(parentName);
      addPlayerform.$el.find("input[name='parent-email']").val(parentEmail);

      addPlayerform.$el.submit();

      var request = $.ajax.mostRecentCall.args[0];
      var data = JSON.parse(request.data);

      expect(request.type).toEqual("POST");
      expect(request.url).toEqual("/api/v1/users/invitations?team_id=undefined&save_type=JUNIOR");
      expect(data.user.name).toBe(juniorName);
      expect(data.user.parent_name).toBe(parentName);
      expect(data.user.email).toBe(parentEmail);
    });

  });

});
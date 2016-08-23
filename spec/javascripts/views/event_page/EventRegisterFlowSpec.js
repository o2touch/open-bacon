describe("BFApp.Views.EventRegisterFlow", function() {

  var layout;

  beforeEach(function() {
    window.ActiveApp = {
      CurrentUser: new App.Modelss.User(),
      Event: new App.Modelss.Event({
        location: new App.Modelss.Location(),
        team: new Backbone.Model()
      })
    };
    layout = new BFApp.Views.EventRegisterFlow();
    spyOn(BFApp.validation, "isName").andCallThrough();
    layout.render();

    //$("body").append(layout.$el);
  });

  afterEach(function() {
    //layout.$el.remove();
    layout = null;
  });

  it("displays the email/facebook form", function() {
    expect(layout.$el.find("input[name=email]")).toExist();
  });



  describe("adding an email and submitting", function() {

    beforeEach(function() {
      jasmine.Clock.useMock();

      // first add an email to skip to the next (form) stage
      layout.$el.find("input[name=email]").val("valid@email.com");
      layout.$el.find("#er-facebook form").submit();
      // skip the 500ms setTimeout()
      jasmine.Clock.tick(501);
    });

    it("displays the main register form", function() {
      expect(layout.$el.find("input[name=name]")).toExist();
    });



    describe("filling in the form and submitting", function() {

      beforeEach(function() {
        // just call the success method
        spyOn($, "ajax").andCallFake(function(params) {
          params.success({});
        });

        layout.$el.find("input[name=name]").val("Some name");
        layout.$el.find("input[name=dob]").val("26/12/1985");
        layout.$el.find("input[name=gender]").first().prop("checked", true);
        layout.$el.find("input[name=phone]").val("+44 77333 12345");
        // no need for email as pre-populated from before
        layout.$el.find("input[name=type]").first().prop("checked", true);
        layout.$el.find("input[name=password]").val("Some password");
        layout.$el.find("input[name=terms]").prop("checked", true);

        layout.$el.find("#er-form form").submit();
      });

      it("validates the form", function() {
        expect(BFApp.validation.isName).toHaveBeenCalled();
      });

      it("shows the onboarding stage", function() {
        expect(layout.$el.find("button[name=done]")).toExist();
      });

    });

  });

});
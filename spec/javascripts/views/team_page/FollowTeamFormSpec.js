describe("BFApp.Views.FollowTeamForm", function() {

  var view;

  describe("rendering form for LOU on FAFT team page", function() {

    beforeEach(function() {
      window.ActiveApp = {
        CurrentUser: new App.Modelss.User()
      };
      view = new BFApp.Views.FollowTeamForm({
        team: new App.Modelss.Team(),
        division: new App.Modelss.Division(),
        isFollowing: false,
        abTest: "some_test_name" // this is required to fire the metrics request
      });
      view.render();
      // hack to get submit() handler to work in FF (it must be in the DOM)
      $("body").append(view.$el);
    });

    afterEach(function() {
      delete window.ActiveApp;
      // tidy up our hack
      view.$el.remove();
      view = null;
    });

    it("displays the form", function() {
      expect(view.ui.nameInput).toExist();
      expect(view.ui.emailInput).toExist();
      expect(view.ui.passwordInput).toExist();
      expect(view.ui.submitButton).toExist();
    });



    describe("submitting form", function() {

      beforeEach(function() {
        view.ui.nameInput.val("Some Name");
        view.ui.emailInput.val("some.name@email.com");
        view.ui.passwordInput.val("password");
      });

      it("makes the request to the user registrations endpoint", function() {
        var ajaxSpy = spyOn($, "ajax");
        view.ui.submitButton.click();
        expect(ajaxSpy).toHaveBeenCalled();
        var request = $.ajax.mostRecentCall.args[0];
        expect(request.url.indexOf("/api/v1/users/registrations")).not.toEqual(-1);
      });



      describe("on success", function() {

        var ajaxSpy;

        beforeEach(function() {
          // fake the ajax request and call the success function
          ajaxSpy = spyOn($, "ajax").andCallFake(function(params) {
            if (params.success) {
              params.success({});
            }
          });
        });

        // Make no more sense because of ab test
        // it("triggers the right event to show the download popup", function() {
        //   var appVentSpy = spyOn(BFApp.vent, "trigger");
        //   view.ui.submitButton.click();
        //   expect(appVentSpy).toHaveBeenCalled();
        //   var triggerCall = BFApp.vent.trigger.mostRecentCall;
        //   expect(triggerCall.args[0]).toEqual("popup:show");
        // });

        it("sends the metrics", function() {
          view.ui.submitButton.click();
          expect(ajaxSpy).toHaveBeenCalled();
          var request = $.ajax.mostRecentCall.args[0];
          expect(request.url.indexOf("/api/v1/split/finished")).not.toEqual(-1);
        });

      });

    });

  });

});
BFApp.Views.EventRegisterFlow = Marionette.Layout.extend({

  template: "backbone/templates/popups/join_event/event_register_flow",

  regions: {
    facebook: "#er-facebook",
    form: "#er-form",
    onboarding: "#er-onboarding"
  },

  onRender: function() {
    // UPDATE: comment FB shit for now as we ask for extra perms (user_birthday) which now requires a lengthy FB review process
    //if (ActiveApp.CurrentUser.isLoggedIn()) {
      this.showFormStage(ActiveApp.CurrentUser);
    // } else {
    //   this.showFacebookStage();
    // }

    // TESTING - LEO UNCOMMENT THIS TO GET TO ONBOARDING STEP
    /*this.showFormStage(new App.Modelss.User());
    this.showOnboardingStage();*/
  },

  /*showFacebookStage: function() {
    var facebookView = new BFApp.Views.EventRegisterFacebook();
    this.facebook.show(facebookView);

    this.listenToOnce(facebookView, "next", this.showFormStage);
  },*/

  showFormStage: function(user) {
    var formView = new BFApp.Views.EventRegisterForm({
      model: user
    });
    this.form.show(formView);

    this.listenToOnce(formView, "next", this.showOnboardingStage);

    // insert nice transitions here
    this.form.$el.removeClass("hide");
    // we may have skipped the facebook step
    if (this.facebook.currentView) {
      this.facebook.$el.addClass("hide");
      // AND must always close views when done
      this.facebook.close();
    }
  },

  showOnboardingStage: function() {
    // disable closing the popup, as we want to force them to click "Done", which will reload the page
    BFApp.vent.trigger("popup:disable:close");

    var view = new BFApp.Views.EventRegisterOnboarding();
    this.onboarding.show(view);

    // insert nice transitions here
    this.onboarding.$el.removeClass("hide");
    this.form.$el.addClass("hide");

    // AND must always close views when done
    this.form.close();
  }

});
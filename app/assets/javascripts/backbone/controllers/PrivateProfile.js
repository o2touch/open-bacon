BFApp.Controllers.PrivateProfile = BFApp.Controllers.NonMemberProfile.extend({

  /* Display godbar message */
  showHeader: function(message) {
    BFApp.vent.trigger("alert:godbar", message);
  },

  /* Show Call to action + text */
  showCTASignup: function(CTAcontext) {
    var that = this;
    var ctaView = new BFApp.Views.NonMemberProfileCtaSignup({
      className: "classic popover private-cta",
      who: (ActiveApp.ProfileTeam) ? ActiveApp.ProfileTeam.get("name") : ActiveApp.ProfileUser.get("name"),
      context: CTAcontext

    });
    this.layout.form.show(ctaView);
  },

  /* Show user card */
  showUserCard: function() {
    var userCardView = new BFApp.Views.UserCardView({
      model: ActiveApp.ProfileUser,
      className: "eleven columns centered"
    });
    this.layout.card.show(userCardView);
  }

});
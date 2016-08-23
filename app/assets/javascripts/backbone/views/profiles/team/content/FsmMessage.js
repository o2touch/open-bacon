BFApp.Views.FsmMessage = Marionette.ItemView.extend({

  className: "team-onboarding-godbar columns nine centered",

  triggers: {
    "click #fsm-msg-button": "button:click"
  },

  onRender: function() {
    this.$el.css({
      "opacity": "0"
    });
    this.$el.animate({
      opacity: 1,
    }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
  }

});
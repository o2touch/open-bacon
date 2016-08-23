BFApp.Views.RideConclusion = Marionette.ItemView.extend({

  template: "backbone/templates/ride/ride_conclusion",
  className: "ride-box conclusion",
  triggers: {
    "click .exit": "exit:clicked"
  },

  onShow: function() {


    this.$el.css({
      "position": "absolute",
      "z-index": "4003",
      "top": ($(window).scrollTop() + $(window).height() / 5)
    });


    $("html, body").animate({
      scrollTop: ($(window).scrollTop() + $(window).height() / 5) - 120
    }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
  },


});
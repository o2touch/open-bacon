BFApp.Views.RideStep = Marionette.ItemView.extend({

  template: "backbone/templates/ride/ride_step",
  className: "ride-box",
  triggers: {
    "click .next": "next:clicked",
    "click .exit": "exit:clicked"
  },

  serializeData: function() {
    return {
      title: this.options.title,
      description: this.options.description
    }
  },

  initialize: function() {
    var that = this;
    $(window).resize(function() {
      that.positionElement();
    })
  },

  onShow: function() {
    this.positionElement();
    $("html, body").animate({
      scrollTop: this.options.stickyElement.offset().top - $("#r-navigation").height() - $("#r-godbar").height() - 12
    }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
  },

  positionElement: function() {
    var offset = this.options.stickyElement.offset();
    var positionRight = (this.options.stickyElement.offset().left + this.options.stickyElement.width() + 250 < $(window).width());


    if (positionRight) {
      left = offset.left + this.options.stickyElement.outerWidth() + 12;
    } else {
      left = offset.left - 250 - 12;
    }

    this.$el.css({
      "position": "absolute",
      "z-index": "4003",
      "top": offset.top - 40,
      "left": left
    });


  }



});
BFApp.Controllers.Godbar = Marionette.Controller.extend({

  showGodbar: function(options) {
    var that = this;

    /* If a godbar is present, hide it then show the new godbar (callback) */
    if (!_.isUndefined(BFApp.godbar.currentView)) {
      BFApp.vent.trigger("hide:godbar", {
        callback: function() {
          that.showLayout(options);
        }
      });
    }

    /* else, just show the new godbar */
    else {
      that.showLayout(options);
    }
  },

  showLayout: function(options) {

    /* Generate the godbar (layout), the show it */
    var godbarLayoutView = new BFApp.Views.GodbarLayout(options);
    BFApp.godbar.show(godbarLayoutView);

    /* get the (min-)Height of the godbar (animation purpose) */
    var minHeight = BFApp.godbar.currentView.$el.outerHeight();

    /* Hide the godbar (css), the show it (animate) */
    BFApp.godbar.currentView.$el.css({
      "margin-top": -minHeight
    }).animate({
      "margin-top": 0
    }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn, function() {

      /* Execute callback if existing */
      if (!_.isUndefined(options) && _.isFunction(options.callback)) {
        options.callback();
      }
    });

    /* For fixed godbar, perform animation of Godbar Region,
      in the order, the rest of the page will adapt to the godbar
      size even if fixed. */
    if (BFApp.godbar.currentView.$el.hasClass("fixed")) {
      BFApp.godbar.$el.animate({
        height: minHeight
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);

      /* Bind same logic in case of resize */
      $(window).on("resize", this.adjustCssPosition).resize();
    }
  },

  /* Same logic as line:42, we need to fake the godbar presence if fixed */
  adjustCssPosition: function() {
    if (BFApp.godbar.currentView.$el.hasClass("fixed")) {
      BFApp.godbar.$el.css({
        height: BFApp.godbar.currentView.$el.outerHeight()
      });
    }
  },

  hideGodbar: function(options) {

    /* If a godbar is present */
    if (!_.isUndefined(BFApp.godbar.currentView)) {

      /* get the (min-)Height of the godbar (animation purpose) */
      var minHeight = BFApp.godbar.currentView.$el.outerHeight();

      /* Hide the godbar, the close the godbar region & execute callback if existing */
      BFApp.godbar.currentView.$el.css({
        "overflow": "hidden"
      }).animate({
        height: 0,
        padding: 0
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingOut, function() {
        BFApp.godbar.close();
        if (!_.isUndefined(options) && _.isFunction(options.callback)) {
          options.callback();
        }
      });

      /* For fixed godbar, perform animation of Godbar Region,
      in the order, the rest of the page will adapt to the godbar
      size even if fixed. */
      if (BFApp.godbar.currentView.$el.hasClass("fixed")) {
        BFApp.godbar.$el.animate({
          height: 0
        }, BFApp.constants.animation.time, BFApp.constants.animation.easingOut, function() {

          /* Avoid css glitch by remove css value */
          $(this).css({
            "height": ""
          });
        });

        /* Unbind precedent resize logic */
        $(window).off("resize", this.adjustCssPosition);
      }

      /* else, execute callback if existing */
    } else {
      if (!_.isUndefined(options) && _.isFunction(options.callback)) {
        options.callback();
      }
    }
  }

});
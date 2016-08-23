  var BFApp = new Marionette.Application();
	
	// Namespacing
	_.extend(BFApp, {
	  Controllers: {},
	  Models: {},
	  Views: {},
	  Routers: {}
	});
	
	/* Marionette Template Setup */
	Backbone.Marionette.Renderer.render = function(template, data) {
	  if (_.isFunction(template)) var template = template();
	  if (!JST[template]) throw "Template '" + template + "' not found!";
	  return JST[template](data);
	};

$(document).ready(function() {
  
  
  
  if ($(".homepage").length) {

    $(".main-header").height($(window).height());

    $(".learn-more").click(function() {
      if ($(window).height() < 800) {
        $("html, body").animate({
          "scrollTop": 800
        }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
      } else {
        $("html, body").animate({
          "scrollTop": $(window).height()
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    });



    var feature2 = $(".feature:eq(1)");
    $(".bubble-green").width(0).height(0).css({
      "margin-top": "41px"
    });
    $(".bubble-green p").css({
      "opacity": "0"
    });

    $(".bluefields-iframe").css({
      "opacity": "0"
    });

    feature2.waypoint(function(direction) {
      if (direction == "down") {
        $(".bluefields-iframe").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
        $(".bubble-green").animate({
          "width": "56px",
          "height": "41px",
          "margin-top": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing, function() {
          $(".bubble-green p").animate({
            "opacity": "1"
          }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
        });
      } else if (direction == "up") {
        $(".bluefields-iframe").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
        $(".bubble-green p").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing, function() {
          $(".bubble-green").animate({
            "width": "0",
            "height": "0",
            "margin-top": "41px"
          }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
        });
      }
    }, {
      offset: function() {
        return 250;
      }
    });


    feature2.waypoint(function(direction) {
      if (direction == "down") {
        $(".availibility-title:eq(1)").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing, function() {
          $(this).animate({
            "height": "0"
          }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
        });
      } else if (direction == "up") {
        $(".availibility-title:eq(1)").animate({
          "height": "48px"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing, function() {
          $(this).animate({
            "opacity": "1"
          }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
        });
      }
    }, {
      offset: function() {
        return 150;
      }
    });


    $(".comment").css({
      "opacity": "0"
    });
    var feature3 = $(".feature:eq(2)");
    feature3.waypoint(function(direction) {
      if (direction == "down") {
        $(".comment:eq(0)").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      } else if (direction == "up") {
        $(".comment:eq(0)").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    }, {
      offset: function() {
        return 250;
      }
    });

    feature3.waypoint(function(direction) {
      if (direction == "down") {
        $(".comment:eq(1)").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      } else if (direction == "up") {
        $(".comment:eq(1)").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    }, {
      offset: function() {
        return 200;
      }
    });

    feature3.waypoint(function(direction) {
      if (direction == "down") {
        $(".comment:eq(2)").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      } else if (direction == "up") {
        $(".comment:eq(2)").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    }, {
      offset: function() {
        return 150;
      }
    });


    var feature4 = $(".feature:eq(3)");
    $(".feature-image .arrow-one, .feature-image .arrow-two, .feature-image .calendar").css({
      "opacity": "0"
    });
    feature4.waypoint(function(direction) {
      if (direction == "down") {
        $(".feature-image .arrow-one").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      } else if (direction == "up") {
        $(".feature-image .arrow-one").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    }, {
      offset: function() {
        return 250;
      }
    });

    feature4.waypoint(function(direction) {
      if (direction == "down") {
        $(".feature-image .calendar").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      } else if (direction == "up") {
        $(".feature-image .calendar").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    }, {
      offset: function() {
        return 200;
      }
    });

    feature4.waypoint(function(direction) {
      if (direction == "down") {
        $(".feature-image .arrow-two").animate({
          "opacity": "1"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      } else if (direction == "up") {
        $(".feature-image .arrow-two").animate({
          "opacity": "0"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      }
    }, {
      offset: function() {
        return 150;
      }
    });

    $(".testimonials").waypoint(function(direction) {
      if (direction == "down") {
        window.clearInterval(itvl);
      } else if (direction == "up") {
        itvl = window.setInterval(function() {
          next();
        }, 9000);
      }
    }, {
      offset: function() {
        return 150;
      }
    });

    $(".contact-scroll").click(function() {
      $("html, body").animate({
        scrollTop: $(document).height()
      }, BFApp.constants.animation.time, BFApp.constants.animation.easing);
      return false;
    });

    var navigationParalax = $(".main-navigation");
    var headerContentParalax = $(".header-content");
    var quoteParalax = $(".quote");




    $(window).load(function() {
      $(document).scroll(function() {

        navigationParalax.css({
          "top": function() {
            if ($(document).scrollTop() < $(window).height() - 100) {
              navigationParalax.removeClass("fixed");
              return $(document).scrollTop() / -17;
            } else if ($(document).scrollTop() > $(window).height() - 100 && $(document).scrollTop() < $(window).height() - 1) {
              return -80;
            } else if ($(document).scrollTop() > $(window).height() - 1) {
              navigationParalax.addClass("fixed");
              return 0;
            }
          }
        });

        headerContentParalax.css({
          "top": function() {
            var offsetTop = (($(window).height() / 2) - ($(".header-content").height() / 2) - 100);
            if (offsetTop < 165) {
              offsetTop = 165;
            }
            return ($(document).scrollTop() / -10) + offsetTop;
          }
        });
      }).scroll();
    });


    itvl = window.setInterval(function() {
      next();
      animateState = true;
    }, 9000);


    var animateState = false;

    var currentTestimonial = 0;
    $(".testimonials ul li").hide().css({
      "left": "2000px"
    });
    $(".testimonials ul li:eq(" + currentTestimonial + ")").show().css({
      "left": "0"
    });


    function next() {
      if (!animateState) {
        animateState = true;
        $(".testimonials ul li:eq(" + currentTestimonial + ")").animate({
          "left": "-2000"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn, function() {
          $(this).hide();
          currentTestimonial++;
          if (currentTestimonial + 1 > $(".testimonials ul li").length) {
            currentTestimonial = 0;
          }
          $(".testimonials ul li:eq(" + currentTestimonial + ")").show().css({
            "left": "2000px"
          }).animate({
            "left": "0"
          }, BFApp.constants.animation.time, BFApp.constants.animation.easing, function() {
            animateState = false;
          });
        });
      }
    }

    function prev() {
      if (!animateState) {
        animateState = true;
        $(".testimonials ul li:eq(" + currentTestimonial + ")").animate({
          "left": "2000"
        }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn, function() {
          $(this).hide();
          currentTestimonial -= 1;
          if (currentTestimonial < 0) {
            currentTestimonial = $(".testimonials ul li").length - 1;
          }

          $(".testimonials ul li:eq(" + currentTestimonial + ")").show().css({
            "left": "-2000px"
          }).animate({
            "left": "0"
          }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn, function() {
            animateState = false;
          });
        });
      }
    }

    $(".testimonials").hover(function() {
      window.clearInterval(itvl);
    }, function() {
      itvl = window.setInterval(function() {
        next();
      }, 9000);
    });

    $(".next").click(function() {
      next();
      animateState = true;
    });

    $(".prev").click(function() {
      prev();

    });
    
    

    
    $(".home-login").css({"opacity":"0"});


  }

});
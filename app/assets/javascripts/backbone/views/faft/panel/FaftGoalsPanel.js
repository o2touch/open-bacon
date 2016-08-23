BFApp.Views.FaftGoalPanel = Marionette.ItemView.extend({

  template: "backbone/templates/faft/panel/faft_goals_panel",

  ui: {
    "goals": ".goals",
    "progressBar": ".goal-progress-bar",
    "progressText": ".goal-percent-text",
    "progressTitle": "h3"
  },

  events: {
    "click .goal": "triggerHelper"
  },

  triggerHelper: function(e) {
    if ($(e.currentTarget).hasClass("done")) return;
    this.trigger($(e.currentTarget).data("trigger"));
    analytics.track("Clicked Goal Panel Item", {
      "goal": $(e.currentTarget).data("track")
    });
  },

  addGoal: function(goal) {
    goal.stateClass = goal.stateClass || "";
    var goalHtml = $('<li class="goal"></li>');
    goalHtml.addClass(goal.stateClass);
    goalHtml.text(goal.title);
    goalHtml.data("trigger", goal.dataTrigger);
    goalHtml.data("track", goal.dataTrack);
    goalHtml.data("percent", goal.percent);
    goalHtml.attr("data-position", goal.position);
    goalHtml.prepend('<i class="bf-icon check"></i>');
    
    this.ui.goals.append(goalHtml);
    this.calculateCompletion();
  },

  toggleGoal: function(goalIndex) {
    this.ui.goals.find(".goal[data-position="+goalIndex+"]").toggleClass("done");
    this.calculateCompletion();
  },

  completeGoal: function(goalIndex) {
    this.ui.goals.find(".goal[data-position="+goalIndex+"]").addClass("done");
    this.calculateCompletion();
  },

  resetGoal: function(goalIndex) {
    this.ui.goals.find(".goal[data-position="+goalIndex+"]").removeClass("done");
    this.calculateCompletion();
  },

  calculateCompletion: function() {
    var that = this;
    var totalGoal = this.ui.goals.find(".goal").length;
    var percent = 0;
    
    this.ui.goals.find(".goal.done").each(function(){
      percent+= $(this).data("percent");
    });

    var setValue = function(valueInPercent) {
      that.ui.progressBar.val(Math.round(valueInPercent));
      that.ui.progressText.text(Math.round(valueInPercent) + "%");
    };

    jQuery({
      percentValue: that.ui.progressBar.val()
    }).animate({
      percentValue: percent
    }, {
      duration: BFApp.constants.animation.time,
      easing: BFApp.constants.animation.easing,
      step: function() {
        setValue(this.percentValue);
      },
      complete: function() {
        setValue(this.percentValue);
      }
    });

    if (percent == 100) {
      this.ui.progressTitle.text("Completed");
    } else {
      this.ui.progressTitle.text("What to do next:");
    }
    
    this.orderGoal();
    
  },
  
  orderGoal: function(){
    var done = this.ui.goals.find(".goal.done");
    var notDone = this.ui.goals.find(".goal:not(.done)");
    
    this.ui.goals.append(notDone).append(done);
  },
  
  
  
});
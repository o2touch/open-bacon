BFApp.Views.ScheduleFixtureRow = Marionette.ItemView.extend({

  tagName: "div",

  className: "fixture",

  template: "backbone/templates/profiles/league/content/schedule/schedule_fixture_row",

  initialize: function(options) {
    this.currentResult = this.model.get("result");
    if (this.currentResult) {
      this.listenTo(this.currentResult, 'change', this.reRender);
    }
    this.currentPoints = this.model.get("points");
    if (this.currentPoints) {
      this.listenTo(this.currentPoints, 'change', this.reRender);
    }
    this.listenTo(this.model, 'change', this.modelChange);
    this.ld = options.ld;

    var scoringSystem = this.ld.division.get("scoring_system");
    this.scoringSystem = (scoringSystem) ? scoringSystem.toLowerCase() : "generic";
    // this.$el.addClass(this.scoringSystem);
  },

  modelChange: function() {
    // if user adds new result model, we must start listening to it for changes
    var result = this.model.get("result");
    if (!this.currentResult && result) {
      this.stopListening(this.currentResult);
      this.currentResult = result;
      this.listenTo(this.currentResult, "change", this.reRender);
    }
    // same for points model (need to show/hide "no points set" label)
    var points = this.model.get("points");
    if (!this.currentPoints && points) {
      this.stopListening(this.currentPoints);
      this.currentPoints = points;
      this.listenTo(this.currentPoints, "change", this.reRender);
    }

    this.reRender();
  },

  reRender: function() {
    // here we set changed=true so we know not to fade it in on render
    this.model.set("changed", true, {
      silent: true
    });
    this.render();
  },

  serializeData: function() {
    var isInFuture = this.model.isInFuture();
    var isCancelled = (this.model.get("status") == 1);

    var date = this.model.getDateObj();
    var time = null;
    if (date) {
      time = date.get12hrTimeObject();
    }

    var points = this.model.get("points");
    var hasPoints = (points &&
      (!_.isEmpty(points.get("home_points")) || !_.isEmpty(points.get("away_points"))));

    // editable if admin and either it's a future fixture, or if in past:
    // it's not cancelled and also that the division flags let us edit anything
    var resultEditable = (!isCancelled && (this.ld.division.get("track_results") || this.ld.division.get("show_standings")));
    var isEditable = (this.ld.adminUser && (isInFuture || resultEditable));

    return {
      time: (this.model.get("time_tbc")) ? null : time,
      isCancelled: isCancelled,
      isEdited: (this.model.get("edited")),
      hasPoints: hasPoints,
      isInFuture: isInFuture,
      showEditButton: isEditable
    };
  },

  onBeforeClose: function() {
    var region = this.$el.closest("#r-schedule-preview");
    // if this is a preview we need to clear out the rest of the HTML (date box stuff)
    if (region.length) {
      region.append(this.$el);
      region.find(".fixtures-group").remove();
    }
  },

  addCorrectClass: function() {
    this.$el.removeClass("no-team cancelled edited draw home-team-won away-team-won");

    if (this.model.get("status") == 1) {
      this.$el.addClass("cancelled");
    } else if (this.model.get("edited")) {
      this.$el.addClass("edited");
    }

    var result = this.model.get("result");
    if (result) {
      this.$el.addClass("has-results");
      if (result.get("draw")) {
        this.$el.addClass("draw");
      } else if (result.get("home_team_won")) {
        this.$el.addClass("home-team-won");
      } else if (result.get("away_team_won")) {
        this.$el.addClass("away-team-won");
      }
    }

    var homeTeam = this.model.get("home_team");
    var awayTeam = this.model.get("away_team");
    if (!homeTeam && !awayTeam && this.model.get("title")) {
      this.$el.addClass("no-team");
    }
  },

  onRender: function() {
    // mark this row with the fixture-id for use later
    this.$el.data("fixture-id", this.model.get("id"));

    this.addCorrectClass();

    if (this.model.get("changed") == null) {
      this.$el.css({
        "opacity": "0"
      });
      this.$el.animate({
        "opacity": "1"
      }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
    }

    this.updatePreview();

    this.renderSportSpecificContent();
  },

  renderSportSpecificContent: function() {
    var region = this.$el.find(".sport-specific-content");
    var homeTeam = this.model.get("home_team");
    var awayTeam = this.model.get("away_team");
    var hasResult = (this.model.get("result") !== null);
    var data = {
      isInFuture: this.model.isInFuture(),
      title: this.model.get("title"),
      homeTeam: homeTeam,
      homeTeamImg: (homeTeam) ? homeTeam.get("profile_picture_thumb_url") : BFApp.constants.GENERIC_TEAM_THUMB,
      awayTeam: awayTeam,
      awayTeamImg: (awayTeam) ? awayTeam.get("profile_picture_thumb_url") : BFApp.constants.GENERIC_TEAM_THUMB,
      homeResultStr: (hasResult) ? this.model.get("result").get("home_final_score_str") : null,
      awayResultStr: (hasResult) ? this.model.get("result").get("away_final_score_str") : null
    };
    BFApp.renderTemplate(region, "partials/fixture_rows/" + this.scoringSystem, data);
  },

  updatePreview: function() {
    // if this is a preview, update it's date box
    if (this.model.isNew()) {
      var date = this.model.getDateObj();
      if (date) {
        var data = {
          dateId: date.format("YYYY-MM-DD"),
          day: date.date(),
          month: date.format("MMM")
        };
        // if we havent yet inserted the date box, do it now
        if (!this.$el.siblings(".date").length) {
          var region = this.$el.closest("#r-schedule-preview");
          BFApp.renderTemplate(region, "partials/fixture-group-date", data);
          region.find(".fixtures-group").append(this.$el);
        }
        // update the date in the box
        var dateBox = this.$el.siblings(".date");
        dateBox.children(".day").text(data.day);
        dateBox.children(".month").text(data.month);
      }
    }
  }

});
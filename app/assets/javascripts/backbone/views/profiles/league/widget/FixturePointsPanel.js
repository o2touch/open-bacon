BFApp.Views.FixturePointsPanel = Marionette.ItemView.extend({


  className: "panel points-panel",

  ui: {
    "saveButton": "button[name='save']"
  },

  events: {
    "click a[name='cancel']": "cancelEdit",
    "click button[name='save']": "save"
  },

  initialize: function(options) {
    this.ld = options.ld;
    this.fixture = options.fixture;
    // this.$el.addClass(this.options.scoringSystem);
    this.template = "backbone/templates/profiles/league/widget/points_panels/" + this.options.scoringSystem;

    this.model = this.fixture.get("points") || new App.Modelss.Points();
    this.model.store();
  },

  serializeData: function() {
    var homeTeam = this.fixture.get("home_team");
    var awayTeam = this.fixture.get("away_team");

    return {
      homeTeamName: (homeTeam) ? homeTeam.get("name") : "",
      awayTeamName: (awayTeam) ? awayTeam.get("name") : "",
      homePoints: this.model.get("home_points"),
      awayPoints: this.model.get("away_points"),
      pointsCategories: this.options.pointsCategories
    };
  },

  onRender: function() {
    this.$el.submit(function() {
      return false;
    });
  },

  cancelEdit: function() {
    this.model.restore();
    this.render();
    analytics.track('UX: Clicked division points panel cancel', {
      user_id: ActiveApp.CurrentUser.get("id"),
      division_id: this.ld.division.get("id"),
      fixture_id: this.fixture.get("id")
    });
    return false;
  },

  updateModelAttributes: function() {
    var that = this;
    _.each(this.$(".points-element"), function(item) {
      var el = $(item);
      var key = el.data("points-type");

      // NOTE: boxes can be emtpy, if so: delete that key from existing values on model
      var homePoints = that.model.get("home_points");
      var homePointsVal = el.find(".home_points").val();
      if (homePointsVal.length) {
        homePoints[key] = homePointsVal;
      } else {
        delete homePoints[key];
      }

      var awayPoints = that.model.get("away_points");
      var awayPointsVal = el.find(".away_points").val();
      if (awayPointsVal.length) {
        awayPoints[key] = awayPointsVal;
      } else {
        delete awayPoints[key];
      }
    });
  },

  // check every input: if it's not empty it can only contain a number
  validate: function() {
    var result = true;
    _.each(this.$("input[type='text']"), function(input) {
      var el = $(input);
      if (el.val().length) {
        var isValidInput = BFApp.validation.validateInput({
          htmlObject: el,
          regex: BFApp.validation.regex.num
        });
        result = (result && isValidInput);
      }
    });
    return result;
  },

  save: function() {
    if (this.validate()) {
      this.updateModelAttributes();

      var that = this;
      disableButton(this.ui.saveButton);

      var options = {
        success: function(data) {
          // if creating new points model, link it to fixture model
          if (that.fixture.get("points") === null) {
            that.fixture.set("points", that.model);
          }
          enableButton(that.ui.saveButton);
          that.trigger("reload:standings");
          // as we dont close the form on save, we must update the stored attributes
          // incase user now makes another change then hits cancel
          that.model.store();
        },
        error: function() {
          errorHandler({
            button: that.ui.saveButton
          });
        }
      };

      if (this.model.isNew()) {
        this.model.createOnFixture(this.fixture, options);
      } else {
        this.model.saveUpdates(options);
      }

      analytics.track('UX: Clicked division points panel save', {
        user_id: ActiveApp.CurrentUser.get("id"),
        division_id: this.ld.division.get("id"),
        fixture_id: this.fixture.get("id")
      });
    }

    return false;
  }

});
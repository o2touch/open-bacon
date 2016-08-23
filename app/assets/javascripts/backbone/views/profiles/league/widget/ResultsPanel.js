BFApp.Views.ResultsPanel = Marionette.ItemView.extend({

  className: "panel results-panel",

  ui: {
    "saveButton": "button[name='save']",
    "homeScore": "input[name='home_score']",
    "awayScore": "input[name='away_score']"
  },

  events: {
    "click a[name='cancel']": "cancelEdit",
    "click button[name='save']": "save"
  },

  initialize: function(options) {
    this.ld = options.ld;
    this.fixture = options.fixture;
    this.$el.addClass(this.options.scoringSystem);

    this.template = "backbone/templates/profiles/league/widget/results_panels/" + this.options.scoringSystem;

    this.model = this.fixture.get("result") || new App.Modelss.Result();
    this.model.store();

    this.scoreAttr = this.getScoreAttr();
  },

  getScoreAttr: function() {
    if (this.options.scoringSystem == "generic") {
      return "full_time";
    } else {
      return "final";
    }
  },

  serializeData: function() {
    var homeTeam = this.fixture.get("home_team");
    var awayTeam = this.fixture.get("away_team");
    var defaultColour = '4fade3';

    return {
      homeColour1: (homeTeam) ? homeTeam.get('colour1') : defaultColour,
      homeColour2: (homeTeam) ? homeTeam.get('colour2') : defaultColour,
      homeTeamName: (homeTeam) ? homeTeam.get('name') : "",
      homeTeamImg: (homeTeam) ? homeTeam.get('profile_picture_small_url') : BFApp.constants.GENERIC_TEAM_SMALL,

      awayColour1: (awayTeam) ? awayTeam.get('colour1') : defaultColour,
      awayColour2: (awayTeam) ? awayTeam.get('colour2') : defaultColour,
      awayTeamName: (awayTeam) ? awayTeam.get('name') : "",
      awayTeamImg: (awayTeam) ? awayTeam.get('profile_picture_small_url') : BFApp.constants.GENERIC_TEAM_SMALL,

      homeScore: this.model.get("home_score"),
      awayScore: this.model.get("away_score"),
      scoreAttr: this.scoreAttr
    };
  },

  cancelEdit: function() {
    this.model.restore();
    this.render();
    analytics.track('UX: Clicked division results panel cancel', {
      user_id: ActiveApp.CurrentUser.get("id"),
      division_id: this.ld.division.get("id"),
      fixture_id: this.fixture.get("id")
    });
    return false;
  },

  validate: function() {
    var isValidHomeScore = BFApp.validation.isScore({
      htmlObject: this.ui.homeScore
    });
    var isValidAwayScore = BFApp.validation.isScore({
      htmlObject: this.ui.awayScore
    });
    return (isValidHomeScore && isValidAwayScore);
  },

  save: function() {
    if (this.validate()) {
      this.model.get("home_score")[this.scoreAttr] = this.ui.homeScore.val();
      this.model.get("away_score")[this.scoreAttr] = this.ui.awayScore.val();

      var that = this;
      disableButton(this.ui.saveButton);

      var options = {
        success: function(data) {
          // if creating new results model, link it to fixture model
          if (that.fixture.get("result") === null) {
            that.fixture.set("result", that.model);
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

      analytics.track('UX: Clicked division results panel save', {
        user_id: ActiveApp.CurrentUser.get("id"),
        division_id: this.ld.division.get("id"),
        fixture_id: this.fixture.get("id")
      });
    }

    return false;
  }

})
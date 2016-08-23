BFApp.Views.ScheduleFixtureEdit = BFApp.Views.ScheduleRowEdit.extend({

  template: "backbone/templates/profiles/league/widget/schedule_fixture_edit",

  className: "schedule-fixture-edit",

  events: {
    // fields
    "change #prev-locations": "selectedLocation",
    "change #edit-fixture-home-team": "selectedHomeTeam",
    "change #edit-fixture-away-team": "selectedAwayTeam",
    "click #toggle-location-mode": "toggleLocationMode",
    // sync
    "keyup #edit-fixture-title": "syncTitle",
    "keyup #edit-location": "syncLocation",
    "change #edit-fixture-date, #edit-fixture-hours, #edit-fixture-minutes, #edit-fixture-ampm": "syncDate",
    // actions
    "click button[name='save-fixture']": "save",
    "click a[name='cancel-edit']": "cancelEdit",
    "click button[name='cancel-fixture']": "cancelEvent",
    "click button[name='re-enable']": "enableEvent",
    "click a[name='delete-fixture']": "removeFixture"
  },

  ui: {
    // fields
    "title": "#edit-fixture-title",
    "homeTeam": "#edit-fixture-home-team",
    "awayTeam": "#edit-fixture-away-team",
    "hours": "#edit-fixture-hours",
    "minutes": "#edit-fixture-minutes",
    "ampm": "#edit-fixture-ampm",
    "date": "#edit-fixture-date",
    // location
    "locationInputGroup": ".location-input-group",
    "locationTitle": "#edit-location",
    "locationSearch": "button[name=location-search]",
    "locationMap": "#mapwrapper",
    "locationsDropdown": "#prev-locations",
    "toggleLocationLink": "#toggle-location-mode",
    // actions
    "saveButton": "button[name='save-fixture']",
    "cancelButton": "button[name='cancel-fixture']",
    "enableButton": "button[name='re-enable']"
  },

  initialize: function(options) {
    this.locations = options.locations;
    this.ld = options.ld;
    // used in ScheduleRowEdit.js
    this.rowType = "fixture";

    // store the current state of the model, so we can restore it on cancel
    this.model.store();
  },

  serializeData: function() {
    var date = this.model.getDateObj();
    var time = date.get12hrTimeObject();

    return {
      title: this.model.get("title"),
      locations: this.locations,
      location: this.model.get("location"),
      teams: this.ld.division.get("teams"),
      homeTeamEditable: this.model.get("home_team_editable"),
      awayTeamEditable: this.model.get("away_team_editable"),
      homeTeamId: this.model.get("home_team_id"),
      awayTeamId: this.model.get("away_team_id"),
      isDeletable: this.model.get("is_deletable"),
      time: (this.model.get("time_tbc")) ? {} : time,
      date: date.toDateString(),
      status: this.model.get("status"),
      isNewFixture: (this.model.get("id") == null)
    };
  },

  selectedHomeTeam: function() {
    this.setTeam(this.ui.homeTeam.val(), "home");
  },

  selectedAwayTeam: function() {
    this.setTeam(this.ui.awayTeam.val(), "away");
  },

  setTeam: function(teamId, type) {
    // top (empty) option has value = -1
    if (teamId == "-1") {
      this.model.set(type + "_team", null);
      this.model.set(type + "_team_id", null);
    } else {
      var i = parseInt(teamId, 10);
      // i is index, not id as new locations wont yet have IDs
      var team = this.ld.division.get("teams").get(i);
      this.model.set(type + "_team", team);
      this.model.set(type + "_team_id", i);
    }
  },

  save: function() {
    var homeTeam = this.ui.homeTeam.val();
    var awayTeam = this.ui.awayTeam.val();

    if (this.model.validateEdit(this.ui.title, homeTeam, awayTeam)) {
      var that = this;

      // most attributes are auto synced to model while editing
      // here we make some final tweaks before saving
      var attributes = {
        title: this.ui.title.val().trim(),
        location: this.model.getSaveLocation()
      };
      // update the fake event in the list
      this.model.set(attributes);

      disableButton(this.ui.saveButton);

      var options = {
        success: function(model, response, options) {
          that.finishedSave(model);
        },
        error: function(model, response, options) {
          errorHandler({
            button: that.ui.saveButton
          });
        }
      };

      // if creating new event
      if ((this.model.get("id") == null)) {
        //options.wait = true;
        options.divisionId = this.ld.division.get("id");
        // collection.create means model.save THEN collection.add(model)
        this.ld.division.get("fixtures").create(this.model, options);
      } else {
        this.model.save({}, options);
      }

    }
  },

  removeFixture: function() {
    this.removeRow("Are you sure that you want to remove this fixture?");
    return false;
  },

  onRender: function() {
    this.onRenderCommon();
  },

  onShow: function() {
    this.onShowCommon();
    this.$(".bf-icon.info").tipsy({
      gravity: 'se'
    });
  }

});
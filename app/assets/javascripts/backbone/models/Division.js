App.Modelss.Division = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasMany,
    key: 'fixtures',
    collectionType: 'App.Collections.Fixtures',
    relatedModel: 'App.Modelss.Fixture'
  }, {
    type: Backbone.HasMany,
    key: 'teams',
    collectionType: 'App.Collections.DivisionSeasonTeams', // This uses a extended Collection
    relatedModel: 'App.Modelss.DivisionSeasonTeam' // This uses a extended Collection
  }],

  toJSON: function() {
    return {
      // TODO: will this always be fixed_division now?!
      // if not, add an attribute (with a default) and use that here
      // e.g. this.get("division_type")
      fixed_division: _.clone(this.attributes)
    };
  },

  initialize: function() {
    this.urlRoot = '/api/v1/divisions/' + this.get("id");
  },

  fetchDivisionWithFixtureEdits: function(options) {
    options.url = this.urlRoot + "?edits";
    this.fetch(options);
  },

  fetchDivision: function(options) {
    options.url = this.urlRoot;
    this.fetch(options);
  },

  // TODO: Implement Registration Open/Closed
  isRegistrationOpen: function() {
    open = false;

    applicationOpenSetting = this.get("configurable_settings_hash").applications_open;
    if (typeof applicationOpenSetting != undefined) {
      open = applicationOpenSetting;
    }

    return open;
  },

  openRegistration: function() {
    var that = this;
    this.updateRegistration("update", {
      complete: function(data) {
        that.fetchDivision({});
        that.trigger("change");
      }
    });
  },

  closeRegistration: function() {
    var that = this;
    this.updateRegistration("close", {
      complete: function(data) {
        that.fetchDivision({});
        that.trigger("change");
      }
    });
  },

  updateRegistration: function(action, options) {
    var endpoint_url = "/api/v1/divisions/" + this.get("id") + "/registrations"

    var type = "POST";
    if (action == "close") {
      type = "DELETE";
    }

    $.ajax({
      type: type,
      url: endpoint_url,
      dataType: 'text',
      data: "",
      complete: options.complete
    });
  },

  saveToLeague: function(leagueId, options) {
    options.url = "/api/v1/leagues/" + leagueId + "/fixed_divisions";
    this.save({}, options);
  }

});
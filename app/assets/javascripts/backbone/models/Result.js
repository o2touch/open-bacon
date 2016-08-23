App.Modelss.Result = Backbone.RelationalModel.extend({

  defaults: function() {
    return {
      home_score: {},
      away_score: {}
    };
  },

  createOnFixture: function(fixture, options) {
    options.url = '/api/v1/fixtures/' + fixture.get("id") + '/results';
    this.save({}, options);
  },

  saveUpdates: function(options) {
    options.url = '/api/v1/results/' + this.get("id");
    this.save({}, options);
  },

  toJSON: function() {
    return {
      result: _.clone(this.attributes)
    };
  },

  store: function() {
    this.storedAttributes = _.clone(this.attributes);
  },

  restore: function() {
    this.set(this.storedAttributes);
  }

});
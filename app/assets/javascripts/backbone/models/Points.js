App.Modelss.Points = Backbone.RelationalModel.extend({

  defaults: function() {
    return {
      home_points: {},
      away_points: {}
    };
  },

  createOnFixture: function(fixture, options) {
    options.url = '/api/v1/fixtures/' + fixture.get("id") + '/points';
    this.save({}, options);
  },

  saveUpdates: function(options) {
    options.url = '/api/v1/points/' + this.get("id");
    this.save({}, options);
  },

  toJSON: function() {
    return {
      points: _.clone(this.attributes)
    };
  },

  store: function() {
    this.storedAttributes = _.clone(this.attributes);
  },

  restore: function() {
    this.set(this.storedAttributes);
  }

});
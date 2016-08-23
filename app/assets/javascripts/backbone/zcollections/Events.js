App.Collections.Events = Backbone.Collection.extend({

  model: App.Modelss.Event,

  url: function() {
    var result = "/api/v1/events";
    // will there ever be an id here? leaving this in for backwards compatibility
    if (!_.isUndefined(this.get("id"))) result += "/" + this.get("id");
    return result;
  },

  comparator: function(model) {
    return model.getMyLocalisedDateObj().valueOf();
  },

  getLocations: function() {
    // pluck creates an array of values for the given attribute
    // compact gets rid of empties
    // uniq just returns the uniques
    //return _.uniq(_.compact(this.pluck('location')));

    var locationObjs = this.pluck('location');
    var titleArray = _.invoke(locationObjs, "get", "title");
    return _.uniq(_.compact(titleArray));
  }

});

App.Collections.PastEvents = App.Collections.Events.extend({
  // past events are sorted in reverse order
  comparator: function(model) {
    return -model.getMyLocalisedDateObj().valueOf();
  }
})

// DEPRECATED
App.Collections.Event = App.Collections.Events;
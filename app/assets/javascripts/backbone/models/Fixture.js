App.Modelss.Fixture = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'home_team',
    relatedModel: 'App.Modelss.Team'
  }, {
    type: Backbone.HasOne,
    key: 'away_team',
    relatedModel: 'App.Modelss.Team'
  }, {
    type: Backbone.HasOne,
    key: 'location',
    relatedModel: 'App.Modelss.Location'
  }, {
    type: Backbone.HasOne,
    key: 'result',
    relatedModel: 'App.Modelss.Result'
  }, {
    type: Backbone.HasOne,
    key: 'points',
    relatedModel: 'App.Modelss.Points'
  }],

  sync: function(method, model, options) {
    if (method == "create") {
      options.url = "/api/v1/divisions/" + options.divisionId + "/fixtures";
    } else {
      options.url = '/api/v1/fixtures' + (this.get("id") ? ("/" + this.get("id")) : "");
    }

    Backbone.sync(method, model, options);
  },

  toJSON: function() {
    // dont bother sending back the related team objects
    var attrs = _.omit(this.attributes, "home_team", "away_team");

    // title can be blank, and if so, we must not send it to the server lest they
    // misinterpret that as us wanting to set it to empty string
    if (!attrs.title) {
      delete attrs.title;
    }

    return {
      fixture: attrs
    };
  },

  getAttributes: function() {
    // don't bother storing this extra junk
    var attrs = _.omit(this.attributes, "home_team", "away_team", "location");
    // must clone location object sperately to avoid just having a link to the object
    var location = this.get("location");
    if (location) {
      // ignore id as it gets wiped if the user makes a change
      attrs.location = _.clone(location.attributes);
    }
    return attrs;
  },

  // store a copy of the fixture, so we can later check if it has any changes
  // this is used when editing a fixture etc
  store: function() {
    this.storedAttributes = this.getAttributes();
  },

  hasChanges: function() {
    var currentAttributes = this.getAttributes();

    var currentAttrString = JSON.stringify(currentAttributes);
    var storedAttrString = JSON.stringify(this.storedAttributes);

    return (currentAttrString != storedAttrString);
  },

  restore: function() {
    // we must reset the current (this) object before re-applying the stored attributes
    // else stored value of null/missing will not override a current value
    this.set("location", null);
    this.set(this.storedAttributes);

    // restore pointers to team objects in case they were changed
    if (this.get("home_team_id")) {
      // grab the new full team model from the store
      var homeTeam = App.Modelss.Team.findOrCreate({
        id: this.get("home_team_id")
      });
      this.set("home_team", homeTeam);
    }

    if (this.get("away_team_id")) {
      var awayTeam = App.Modelss.Team.findOrCreate({
        id: this.get("away_team_id")
      });
      this.set("away_team", awayTeam);
    }
  },

  // the event's time as entered upon creation (ignoring timezones)
  getDateObj: function() {
    // time_local is a string of the time as the user entered it, which is exactly
    // what we want to display. But new Date() will think it is UTC and convert it
    // to the user's browser timezone, so we need to convert it back again
    if (this.get("time_local")) {
      /*var date = Date.fromISO(this.get("time_local"));
      return date.convertUTC();*/
      return moment.utc(this.get("time_local"));
    } else {
      return null;
    }
  },

  // the event's time converted the to timezone of the current user's browser
  getMyLocalisedDateObj: function() {
    //return Date.fromISO(this.get("time"));
    return moment(this.get("time"));
  },

  isInFuture: function() {
    return this.getMyLocalisedDateObj().isAfter(moment());
  },

  // you need either one of the teams, or the title
  validateEdit: function(titleElem, homeTeam, awayTeam) {
    if (homeTeam != -1 || awayTeam != -1) {
      return true;
    } else {
      return BFApp.validation.isFixtureTitle({
        htmlObject: titleElem
      });
    }
  },

  getSaveLocation: function() {
    var loc = this.get("location");
    if (loc && loc.isValidWeak()) {
      return loc;
    }
    return null;
  }

});
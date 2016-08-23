App.Modelss.Event = App.Modelss.ActivityItemObject.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'team',
    relatedModel: 'App.Modelss.Team',
    parse: true
  }, {
    type: Backbone.HasOne,
    key: 'user',
    relatedModel: 'App.Modelss.User'
  }, {
    type: Backbone.HasOne,
    key: 'location',
    relatedModel: 'App.Modelss.Location'
  }, {
    type: Backbone.HasMany,
    key: 'teamsheet_entries',
    collectionType: 'App.Collections.TeamsheetEntries',
    relatedModel: 'App.Modelss.TeamsheetEntry'
  }],

  getSaveLocation: function() {
    var loc = this.get("location");
    if (loc && loc.isValidWeak()) {
      return loc;
    }
    return null;
  },

  getLocationTitle: function() {
    var loc = this.get("location");
    if (loc) {
      if (loc.get("title")) {
        return loc.get("title").trim();
      } else if (loc.get("address")) {
        return loc.get("address").trim();
      }
    }
    return "";
  },

  getPriceString: function() {
    var price = this.get("price");
    // must explicitly check for undefined (attribute missing) and null (no value)
    // as 0 is a valid value
    // UPDATE: it's always a string, so even "0" is true, so dont worry
    return (price) ? "£" + price : "";
  },

  getAttributes: function() {
    // don't bother storing this extra junk
    var attrs = _.omit(this.attributes, "team", "user", "teamsheet_entries", "changed", "location");
    // must clone location object sperately to avoid just having a link to the object
    var location = this.get("location");
    if (location) {
      // ignore id as it gets wiped if the user makes a change
      attrs.location = _.clone(location.attributes);
    }
    return attrs;
  },

  // store a copy of the event, so we can later check if it has any changes
  // this is used when editing an event etc
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
    this.set("location", null, {
      silent: true
    });
    this.set(this.storedAttributes);
  },

  parse: function(response) {
    // Backbone Relational stores all ActivityItemObject models together, so we differentiate them
    // by including their type in the ID
    response.relationalId = "event" + response.id;

    // handling events returned from Algolia
    if (response._geoloc) {
      response.location = {
        distance: Math.floor(response._rankingInfo.geoDistance / BFApp.constants.metresInMile),
        title: response.address_title,
        address: response.address,
        lat: response._geoloc.lat,
        lng: response._geoloc.lng
      };
      delete response._geoloc;
      delete response.address;

      // TESTING
      /*if (!response.price) {
        response.price = "20 for members, £30 for non-members";
      }*/
    }

    return response;
  },

  canSetResult: function() {
    return this.isGame() && !this.isInFuture() && !this.isCancelled() && BFApp.rootController.permissionsModel.can("canManageAvailability");
  },

  hasResult: function() {
    return (typeof this.get("score_for") !== "undefined" || typeof this.get("score_against") !== "undefined");
  },

  isGame: function() {
    return (this.get("game_type") === BFApp.constants.eventType.GAME);
  },

  isPractice: function() {
    return (this.get("game_type") === BFApp.constants.eventType.PRACTICE);
  },

  canManageReminders: function() {
    return (this.isOpen() && !this.isPostponed() && BFApp.rootController.permissionsModel.can("canManageAvailability"));
  },

  // an event is "open" if it is in the future and is not cancelled
  isOpen: function() {
    return (this.isInFuture() && !this.isCancelled());
  },

  isPostponed: function() {
    return (this.get("status") === BFApp.constants.eventStatus.POSTPONED);
  },

  isCancelled: function() {
    return (this.get("status") === BFApp.constants.eventStatus.CANCELLED);
  },

  getHref: function(includeDomain) {
    return ((includeDomain) ? "http://o2touch.herokuapp.com" : "") + "/events/" + this.get("id");
  },

  // all "messageable" objects need to have this method
  getTitle: function() {
    return this.get("title");
  },

  sync: function(method, model, options) {
    var that = this;

    if (method == "update" || method == "create") {
      this.toJSON = function() {
        var result = {
          // dont send all this extra junk to the server
          event: _.omit(this.attributes, "team", "user", "teamsheet_entries", "permissions")
        };
        if (options.notify == 1) {
          result.notify = 1;
        }
        return result;
      };
    } else if (method == "delete") {
      this.toJSON = function() {
        return {
          event: {
            id: model.get("id")
          }
        };
      };
    } else {
      this.toJSON = function() {
        return {
          event: _.clone(this.attributes)
        };
      };
    }

    Backbone.sync(method, model, options);
  },

  isInFuture: function() {
    return this.getMyLocalisedDateObj().isAfter(moment());
  },

  getTeamsheetEntry: function(userId) {
    var teamsheet = this.get("teamsheet_entries");
    var entry = null;

    teamsheet.forEach(function(e) {
      if (e.get("user_id") == userId) {
        entry = e;
      }
    });

    return entry;
  },

  userStatus: function(user) {
    var response_status = 3;
    var teamsheet = this.get("teamsheet_entries");

    teamsheet.forEach(function(e) {
      if (e.get("user_id") == user.get("id")) {
        response_status = e.get("response_status");
      }
    });

    return response_status;
  },

  // the event's time as entered upon creation (ignoring timezones)
  getDateObj: function() {
    // time_local is a string of the time as the user entered it, which is exactly
    // what we want to display. But new Date() will think it is UTC and convert it
    // to the user's browser timezone, so we need to convert it back again
    /*var date = Date.fromISO(this.get("time_local"));
    return date.convertUTC();*/
    return moment.utc(this.get("time_local"));
  },

  // the event's time converted the to timezone of the current user's browser
  getMyLocalisedDateObj: function() {
    //return Date.fromISO(this.get("time"));
    return moment(this.get("time"));
  },

  setStatus: function(status, options) {
    var that = this;
    $.ajax({
      type: "put",
      url: that.url(),
      dataType: 'json',
      data: {
        notify: options.notify,
        event: {
          status: status,
        }
      },
      success: options.success,
      error: options.error,
    });
  },

  reSchedule: function(timeLocal, options) {
    var that = this;
    $.ajax({
      type: "put",
      url: that.url(),
      dataType: 'json',
      data: {
        notify: options.notify,
        event: {
          status: BFApp.constants.eventStatus.RESCHEDULED,
          time_local: timeLocal
        }
      },
      success: options.success,
      error: options.error,
    });
  },

  cancel: function(options) {
    var defaults = {
      success: {},
      error: function() {
        errorHandler();
      },
      notify: 1
    };

    if (!_.isUndefined(options)) {
      options = _.defaults(options, defaults);
    }

    if (window.confirm("Cancel event?")) {
      var params = {
        status: 1,
        notify: 1
      };
      this.save(params, options);
    }
    return false;
  },

  enable: function(options) {
    var defaults = {
      success: {},
      error: function() {
        errorHandler();
      }
    };

    if (!_.isUndefined(options)) {
      options = _.defaults(options, defaults);
    }

    this.save({
      status: 0,
      notify: 1
    }, options);

    return false;
  },


  sendInvites: function(options) {
    _.defaults(options, {
      organiserMessage: null
    });

    $.ajax({
      type: "get",
      url: this.getHref() + "/confirm.json",
      data: {},
      dataType: 'json',
      success: function(data) {
        if (_.isFunction(options.success)) {
          options.success(data);
        }
      }
    });
  },

  sendReminders: function(options) {
    options = options || {};
    $.ajax({
      type: "post",
      url: "/api/v1/invite_reminders",
      dataType: 'json',
      data: {
        invite_reminder: {
          user_id: ActiveApp.CurrentUser.get("id"),
          event_id: this.get("id")
        }
      },
      success: function(data) {
        if (_.isFunction(options.success)) {
          options.success(data);
        }
      }
    });

    analytics.track('Sent Reminders', {
      'EventId': this.get("id")
    });
  },

  url: function() {
    return '/api/v1/events' + (this.get("id") ? ("/" + this.get("id")) : "");
  },

  isJuniorEvent: function() {
    return this.get("team").isJuniorTeam();
  },

  // mark a user as available for this event
  markAvailable: function(user, options) {
    this.setAvailability(user, options, 1);
  },

  // mark a user as unavailable for this event
  markUnavailable: function(user, options) {
    this.setAvailability(user, options, 0);
  },

  // set the availability for a user for this event
  setAvailability: function(user, options, response) {
    // update the actual tse object
    var teamsheetEntry = this.getTeamsheetEntry(user.get("id"));
    if (teamsheetEntry !== null) {
      teamsheetEntry.set("response_status", response);
    }

    // tell the server
    options = options || {};
    $.ajax({
      type: "post",
      url: "/api/v1/teamsheet_entries/invite_responses",
      dataType: 'json',
      data: {
        user_id: user.get("id"),
        event_id: this.get("id"),
        response_status: response
      },
      success: function(data) {
        if (_.isFunction(options.success)) {
          options.success(data);
        }
      },
      error: function(data) {
        errorHandler();
      }
    });
  },

  validateEdit: function(titleElem, locationElem, locationRequired) {
    var isTitle = BFApp.validation.isEventName({
      htmlObject: titleElem
    });
    var isLocation = true;
    if (locationRequired) {
      isLocation = BFApp.validation.isLocation({
        require: true,
        htmlObject: locationElem,
        // we must send a model to validate here
        model: this.get("location") || new App.Modelss.Location()
      });
    }
    return (isTitle && isLocation);
  },

  validateScore: function(scoreFor, scoreAgainst) {
    var isValidScoreFor = BFApp.validation.isScore({
      htmlObject: scoreFor
    });
    var isValidScoreAgainst = BFApp.validation.isScore({
      htmlObject: scoreAgainst
    });
    return (isValidScoreFor && isValidScoreAgainst);
  },

  getResponseByDate: function() {
    // response_by is the number of days before event you want to have the responses by
    var result = this.getDateObj();
    var responseBy = this.get("response_by") || 0;
    return result.subtract("days", responseBy);
  },

  lastReminderOldEnough: function() {
    if (!this.get("time_of_last_reminder")) {
      return true;
    }
    var last = moment(this.get("time_of_last_reminder"));
    // threshold for sending out out more reminders is last reminder was sent >1h ago
    var threshold = moment().subtract("hours", 1);
    return (last.isBefore(threshold));
  }

});
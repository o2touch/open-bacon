App.Modelss.TeamsheetEntry = App.Modelss.ActivityItemObject.extend({

  defaults: {
    invite_sent: false,
    response_status: 2
  },

  initialize: function() {
    if (this.get("teamsheet_entry")) {
      this.attributes = this.get("teamsheet_entry");
    }
  },

  relations: [{
    type: Backbone.HasOne,
    key: 'user',
    relatedModel: 'App.Modelss.User'
  }, {
    type: Backbone.HasOne,
    key: 'event',
    relatedModel: 'App.Modelss.Event'
  }],

  parse: function(response, xhr) {
    // Backbone Relational stores all ActivityItemObject models together, so we differentiate them
    // by including their type in the ID
    response.relationalId = "teamsheetentry" + response.id;
    return response;
  },

  url: function() {
    return "/api/v1/teamsheet_entries" + (this.get("id") ? ("/" + this.get("id")) : "");
  },

  toJSON: function() {
    return {
      teamsheet_entry: _.clone(this.attributes)
    };
  },

  markAvailable: function(options) {
    //console.log("App.Modelss.TeamsheetEntry::markAvailable");
    this.setAvailability(options, 1);
  },

  markUnavailable: function(options) {
    //console.log("App.Modelss.TeamsheetEntry::markUnavailable");
    this.setAvailability(options, 0);
  },

  setAvailability: function(options, response) {
    var that = this;
    options = options || {};
    // update the UI instantly
    this.set("response_status", response);

    $.ajax({
      type: "post",
      url: "/api/v1/teamsheet_entries/" + this.get("id") + "/invite_responses",
      dataType: 'json',
      data: {
        response_status: response
      },
      success: function(data) {
        // this change is now handled by Pusher
        //that.set("response_status", 0);
        if (_.isFunction(options.success)) {
          options.success(data);
        }
      },
      error: function(data) {
        that.set("response_status", data.response_status);
        errorHandler();
      }
    });
  }

});
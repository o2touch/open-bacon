App.Collections.TeamsheetEntries = Backbone.LiveCollection.extend({

  model: App.Modelss.TeamsheetEntry,

  unique: true,

  initialize: function(models, options) {
    if (options !== undefined && options.eventId !== undefined) {
      this.eventId = options.eventId;
    }
  },

  url: function() {
    if (this.eventId != undefined) {
      return "/api/v1/events/" + this.eventId + "/teamsheet";
    }

    return "teamsheet_entries.json";
  },

  // sort by name
  comparator: function(model) {
    var user = model.get("user");
    // teamsheet entries on the team page (nested inside event JSON?) dont seem to have user attributes?!
    if (user) {
      var name = user.get("name");
      // and some other tings dont have names on the users?!
      if (name) {
        return name.toLowerCase();
      }
    }
    return "";
  },

  getAwaitingResponse: function() {
    return this.where({
      response_status: 2
    });
  },

  // NOT USED (I THINK) Rob Jul 2012
  sendInvites: function(callback) {
    console.warn("Using a DEPRECATED call SendInvites in TeamsheetEntries Collection");
    var customMessage = $("#custom-message").val();
    $.ajax({
      type: "get",
      url: "/events/" + ActiveApp.Event.get("id") + "/confirm.json",
      dataType: 'json',
      data: {
        user_id: ActiveApp.CurrentUser.get("id"),
        custom_message: customMessage
      },
      success: callback
    });
  },

  userTeamsheetEntry: function(user) {
    var tse = _.find(this.models, function(tse) {
      return (tse.get("user_id") == user.get("id"));
    });
    return tse;
  },

  checkUserInvited: function(user) {
    var tse = _.find(this.models, function(tse) {
      return tse.get("user_id") == user.get("id");
    });
    return tse != undefined;
  },

  getMyTeamsheetEntries: function() {
    var myTeamsheetEntries = [];
    _.each(this.models, function(tse) {
      if (BFApp.uids.indexOf(tse.get("user_id")) != -1) {
        myTeamsheetEntries.push(tse);
      }
    });
    return myTeamsheetEntries;
  },

  getNumPlayersExcludingMe: function() {
    var numPlayers = this.length;
    var currentUserId = ActiveApp.CurrentUser.get("id");
    if (this.where({
      user_id: currentUserId
    }).length) {
      numPlayers--;
    }
    return numPlayers;
  }

});

//DEPRECATED
App.Collections.Teamsheet = App.Collections.TeamsheetEntries;
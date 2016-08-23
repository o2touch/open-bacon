App.Collections.Users = Backbone.Collection.extend({

  model: App.Modelss.User,

  url: function() {
    return "/api/v1/users";
  },

  // sort by name
  comparator: function(model) {
    return model.get("name").toLowerCase();
  },

  filterUsers: function(users) {
    return this.reject(function(user) {
      return _.contains(users, user)
    });
  },

  // as of 7th feb 2013, this is only used for open invite responses
  // previously was used for inviting players on the event page
  inviteAndSave: function(options, callback) {
    if (options.customMessage != undefined && options.organiserMessage == undefined) options.organiserMessage = options.customMessage;
    var defaults = {
      sendInvitesMode: 1
    };
    var options = _.defaults(options || {}, defaults);

    var data = {
      users: JSON.stringify(this.models),
      send_invites_mode: options.sendInvitesMode,
      event_id: ActiveApp.Event.get("id")
    };

    if (!_.isUndefined(options.response_status)) data.response_status = options.response_status;
    //console.log("inviteAndSave with data = %o", data);

    // Custom ajax call instead of just adding to the teamsheet collection and saving
    // BECAUSE we need to perform custom actions on the backend e.g. sending invites
    // and also we don't even know if these people are proper users yet etc.
    var that = this;
    $.ajax({
      type: "post",
      url: "/api/v1/teamsheet_entries",
      dataType: 'json',
      data: {
        teamsheet_entry: data
      },
      success: function(data) {
        //console.log("inviteAndSave success: %o", data);
        //console.log("that.models = %o", that.models);
        //console.log(options.teamsheet);
        // BUG: server is returning empty data as teamsheet entry has already been created
        //options.teamsheet.add(data);
        //console.log(options.teamsheet);
        //App.UninvitedPlayers.remove(that.models);

        if (_.isFunction(callback)) {
          callback(data);
        } else if (_.isFunction(options.success)) {
          options.success(data);
        }
      },
      error: function(data) {
        //console.log("inviteAndSave error");
        if (_.isFunction(callback)) {
          callback(data);
        } else if (_.isFunction(options.error)) {
          options.error(data);
        }
      },
    });
  },

  // returns array of your users (you or your kids), who play in the given team
  getMyPlayersInTeam: function(team) {
    var myUsers = [];
    _.each(this.models, function(user) {
      if (BFApp.uids.indexOf(user.get("id")) != -1 && user.isPlayer(team)) {
        myUsers.push(user);
      }
    });
    return myUsers;
  },

  getNumPlayersExcludingMe: function(team) {
    var players = _.filter(this.models, function(user) {
      return (user.isPlayer(team) && user.id != ActiveApp.CurrentUser.id);
    });
    return players.length;
  },

  hasDemoPlayers: function() {
    var result = false;
    _.each(this.models, function(user) {
      if (user.get("type") == "demo") {
        result = true;
      }
    });
    return result;
  },

  fetchTeamAssociates: function(teamId, options) {
    options.url = "/api/v1/users?team_id=" + teamId;
    this.fetch(options);
  },

  fetchDivisionSeason: function(divisionSeasonId, options) {
    options.url = "/api/v1/users?division_season_id=" + divisionSeasonId;
    this.fetch(options);
  }

});

//DEPRECATED
App.Collections.PlayersCollection = App.Collections.Users;
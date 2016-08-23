App.Modelss.DivisionSeasonTeam = App.Modelss.Team.extend({

  /* Override the sync method to append division_season id */
  sync: function(method, model, options) {
    if (method == "create") {
      if (typeof options.division_season != "undefined") {
        options.url = this.url() + "?division_id=" + options.division_season;
      }
    }

    Backbone.sync(method, model, options);
  },

  getDivisionSeasonRole: function() {
    roles = this.get("team_division_season_roles");
    return roles[0].role;
  },

  setDivisionSeasonRole: function(new_role) {
    roles = this.get("team_division_season_roles");
    roles[0].role = new_role;
    // this.set("team_division_season_roles", roles);
    this.trigger("change:role_status");
  },

  approveForDivison: function(divisionSeasonId) {
    var that = this;

    this.setDivisionSeasonRole(1); //BFApp.constants.divisionSeasonTeamRole.MEMBER);

    this.updateDivisionSeasonRole(divisionSeasonId, "approve", {
      success: function() {},
      error: function() {
        // Handle any errors
        // - could not be a part of this division

        // Reset any changes
        //that.fetch();
      }
    });
  },

  rejectForDivison: function(divisionSeasonId) {
    var that = this;

    this.setDivisionSeasonRole(3); //BFApp.constants.divisionSeasonTeamRole.REJECTED);

    this.updateDivisionSeasonRole(divisionSeasonId, "reject", {
      success: function(data) {},
      error: function(data) {}
    });

  },

  updateDivisionSeasonRole: function(divisionSeasonId, action, options) {
    var that = this;
    var endpoint_url = '/api/v1/division_season/' + divisionSeasonId + '/teams/' + this.get("id") + "/" + action;

    $.ajax({
      type: "POST",
      url: endpoint_url,
      dataType: 'json',
      data: {
        team: that.get("id")
      },
      complete: function(data) {
        if (_.isFunction(options.success)) {
          options.success(data);
        }
      },
      error: function(data) {
        if (_.isFunction(options.error)) {
          options.error(data);
        }
      }
    });
  }

});
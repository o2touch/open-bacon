BFApp.Views.TeamRoleSelectWidget = Marionette.ItemView.extend({

  template: "backbone/templates/panels/user_details/team_role_select_widget",
  tagName: "li",
  className: "team-role-row",

  ui: {
    "teamRoleSelecter": ".team-role-selecter",
    "changeTeamRoleLink": ".change-team-role-link",
    "cancelTeamRoleLink": ".cancel-team-role-link"
  },

  events: {
    "click .change-team-role-link": "showTeamRoleSelecter",
    "click .cancel-team-role-link": "showTeamRoleSelecter"
  },

  initialized: function() {
    this.changed = false;
    this.currentRole = null;
  },

  onShow: function() {
    this.ui.teamRoleSelecter.toggle();
    this.ui.cancelTeamRoleLink.toggle();
    this.changed = false;
  },

  showTeamRoleSelecter: function() {
    this.ui.teamRoleSelecter.toggle();
    this.ui.teamRoleSelecter.val(this.currentRole);
    this.ui.changeTeamRoleLink.toggle();
    this.ui.cancelTeamRoleLink.toggle();
    this.changed = !this.changed;

    return false;
  },

  roleNameMap: {
    0: "Leave Team",
    1: "Player",
    2: "Team Admin",
    3: "Parent",
    4: "Follow Only"
  },

  roleMigrations: function(team) {
    var user = ActiveApp.CurrentUser,
      migrationMap = {},
      isO2TouchTeam = (team.get("tenant_id") === BFApp.constants.getTenantId("O2 Touch"));

    if (team.isJuniorTeam()) {
      if (user.isFollower(team)) {
        this.currentRole = BFApp.constants.teamRole.FOLLOWER;
        migrationMap = {
          4: this.roleNameMap[BFApp.constants.teamRole.FOLLOWER],
          0: this.roleNameMap[0]
        };
      }
      /*
        if the user has a child in the team and wants to leave then their children will be remove
        unless the child has 2 parents

        if they are an organiser and want to leave then same as above except backend will error if there is no other
        organiser in the team

        if follower then remove them

        they user is a parent because they are looking at a junior team! therefore when a user leaves a junior team they lose
        their parent role as well
      */
    } else {

      // ADULT TEAMS

      if (user.isTeamOrganiser(team)) {
        this.currentRole = BFApp.constants.teamRole.ORGANISER;
        migrationMap = {
          2: this.roleNameMap[BFApp.constants.teamRole.ORGANISER],
          1: this.roleNameMap[BFApp.constants.teamRole.PLAYER],
          0: this.roleNameMap[0]
        };
        if (!isO2TouchTeam) {
          migrationMap["4"] = this.roleNameMap[BFApp.constants.teamRole.FOLLOWER];
        }
      } else if (user.isPlayer(team)) {
        this.currentRole = BFApp.constants.teamRole.PLAYER;
        migrationMap = {
          1: this.roleNameMap[BFApp.constants.teamRole.PLAYER],
          0: this.roleNameMap[0]
        };
        if (!isO2TouchTeam) {
          migrationMap["4"] = this.roleNameMap[BFApp.constants.teamRole.FOLLOWER];
        }
      } else if (user.isFollower(team)) {
        this.currentRole = BFApp.constants.teamRole.FOLLOWER;
        migrationMap = {
          4: this.roleNameMap[BFApp.constants.teamRole.FOLLOWER],
          0: this.roleNameMap[0]
        };
      }
    }

    return migrationMap;
  },

  getSelectedRole: function() {
    return this.ui.teamRoleSelecter[0].value;
  },

  serializeData: function() {
    return {
      htmlPic: this.model.getPictureHtml("thumb"),
      team: this.model.get("name"),
      roleMigrations: this.roleMigrations(this.model),
      currentRole: this.currentRole,
      currentRoleName: this.roleNameMap[this.currentRole]
    };
  },
});
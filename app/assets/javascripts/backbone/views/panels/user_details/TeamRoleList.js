BFApp.Views.TeamRoleList = Marionette.CompositeView.extend({

  template: "backbone/templates/panels/user_details/team_role_list",
  tagName: "form",
  emptyView: BFApp.Views.TeamRoleEmptyView,
  className: "team-roles-settings",

  events: {
    "keyup #user-profile-bio": "limit",
    "click button[title='save']": "save",
    "click .link-cancel": "cancel",
  },

  ui: {
    "buttonSave": "button[title='save']",
    "listContainer": ".team-role-list-container"
  },

  appendHtml: function(collectionView, itemView, index) {
    collectionView.ui.listContainer.append(itemView.el);
  },

  getUpdatedTeamRoles: function() {
    teamRoleMap = {};

    this.children.each(function(v) {
      if (v.changed) {
        teamRoleMap[v.model.get('id')] = v.getSelectedRole();
      }
    });

    return teamRoleMap;
  },

  cancel: function(e) {
    e.preventDefault();
    this.trigger("close:popup");
  },

  onRender: function() {
    // in case user manages to submit form normally
    var that = this;
    this.$el.submit(function() {
      that.save();
      return false;
    });

  },

  save: function(e) {
    e.preventDefault();
    var that = this;

    // If team role change, alert the user
    if (!jQuery.isEmptyObject(this.getUpdatedTeamRoles())) {
      if (!window.confirm("Are you sure you want to make changes to your team roles?")) {
        return false;
      }
    }

    disableButton(this.ui.buttonSave);

    var attrs = {
      team_role_changes: this.getUpdatedTeamRoles()
    };

    //console.log(attrs);

    var roles_changed = Object.keys(attrs.team_role_changes).length;

    this.model.save(attrs, {
      success: function(model, response) {
        //that.trigger("close:popup");
        location.reload();
      },
      error: function(model, xhr, options) {
        var errorOptions = {
          button: that.ui.buttonSave
        };
        if (roles_changed) {
          errorOptions.message = "Unable to update your team roles. A quick glace at the help article link for team roles may help you troubleshoot the issue.";
        }
        errorHandler(errorOptions);
      }
    });
  }

});
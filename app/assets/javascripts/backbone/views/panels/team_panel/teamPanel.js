BFApp.Views.TeamPanel = Marionette.Layout.extend({

  template: "backbone/templates/panels/team_panel/team_panel",

  regions: {
    teamList: "#r-team-list",
    teamTenant: "#r-team-tenant",
    teamForm: "#r-team-form"
  },

  ui: {
    addTeamButton: "button[name=add]",
    tenantSelect: "select[name=tenant]"
  },

  events: {
    "click button[name=add]": "showCreateForm",
    "change select[name=tenant]": "changeTenant"
  },

  serializeData: function() {
    return {
      createTeam: this.options.allowTeamCreation
    };
  },

  onShow: function() {
    var teamList = new BFApp.Views.TeamsList({
      collection: this.collection
    });
    this.teamList.show(teamList);
  },

  changeTenant: function(e) {
    var isO2Touch = ($(e.currentTarget).val() == BFApp.constants.getTenantId("O2 Touch"));
    this.showTenantForm(isO2Touch);
  },

  showCreateForm: function() {
    if (ActiveApp.CurrentUser.checkRegistered()) {
      this.ui.addTeamButton.addClass("hide");

      if (!this.teamViewOptions) {
        this.teamViewOptions = {
          model: new App.Modelss.Team(),
          className: "classic",
          type: "new"
        };
      }

      var canCreateO2TouchTeam = ActiveApp.Permissions.get("canCreateO2TouchTeam");
      if (canCreateO2TouchTeam) {
        var tenantView = new BFApp.Views.TenantSelect();
        this.teamTenant.show(tenantView);
      }

      this.showTenantForm(canCreateO2TouchTeam);
    }
  },

  showTenantForm: function(showO2TouchForm) {
    var teamFormView;
    if (showO2TouchForm) {
      teamFormView = new BFApp.Views.O2TouchTeamForm(this.teamViewOptions);
    } else {
      teamFormView = new BFApp.Views.MitooTeamForm(this.teamViewOptions);
    }
    this.teamForm.show(teamFormView);

    this.listenToOnce(teamFormView, "team:edit:cancel", this.hideForm);
    this.listenTo(teamFormView, "team:saved", function(model) {
      window.location = model.getHref();
    });
  },

  hideForm: function() {
    this.teamForm.close();
    this.teamTenant.close();
    this.ui.addTeamButton.removeClass("hide");
  }

});
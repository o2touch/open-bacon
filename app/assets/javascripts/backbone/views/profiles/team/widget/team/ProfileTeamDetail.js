BFApp.Views.ProfileTeamDetail = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/widget/team/team_detail",

  className: "twelve columns",

  events: {
    "click #btn-edit-profile": "showEdit"
  },

  regions: {
    viewProfile: ".team-detail-view",
    editProfile: ".team-detail-edit"
  },

  onRender: function() {
    this.displayView();
  },

  displayView: function() {
    var viewTeam = new BFApp.Views.ProfileTeamDetailView({
      model: this.model
    });
    this.viewProfile.show(viewTeam);

    var that = this;
    viewTeam.on("show:edit", function() {
      that.displayEdit();
    });
  },

  displayEdit: function() {
    var that = this;

    if (!this.editProfile.currentView) {
      var options = {
        model: this.model,
        className: "team-profile-edit-detail classic popover",
        type: "edit"
      };
      var teamForm;
      if (ActiveApp.Tenant.get("name") == "o2_touch") {
        teamForm = new BFApp.Views.O2TouchTeamForm(options);
      } else {
        teamForm = new BFApp.Views.MitooTeamForm(options);
      }
      this.editProfile.show(teamForm);

      teamForm.on("team:saved team:edit:cancel", function() {
        that.editProfile.close();
      });
    } else {
      this.editProfile.close();
    }
  }

});
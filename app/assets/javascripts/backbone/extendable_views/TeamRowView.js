BFApp.Views.TeamRowView = Marionette.Layout.extend({

  tagName: "tr",
  template: "backbone/templates/profiles/league/content/teams/team_row_view",

  regions: {
    actions: ".team-row-actions"
  },

  serializeData: function() {
    return {
      htmlPic: this.model.getPictureHtml("thumb"),
      name: this.model.get("name"),
      created_at: this.model.get("created_at"),
      url: this.model.getHref(),
    };
  },

  onRender: function() {

    var actionsView = new BFApp.Views.TeamRowActionsView({
      team: this.model
    });

    this.actions.show(actionsView);
  }

});
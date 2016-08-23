BFApp.Views.MemberRowView = Marionette.ItemView.extend({
  tagName: "tr",
  template: "backbone/templates/profiles/league/content/members/member_row_view",

  ui: {
    actions: ".team-row-actions"
  },

  serializeData: function() {
    return {
      htmlPic: this.model.getPictureHtml("thumb"),
      name: this.model.get("name"),
      created_at: this.model.get("created_at"),
      url: this.model.getHref()
    };
  },

  onRender: function() {

    var actionsView = new BFApp.Views.MemberRowActionsView({
      user: this.model
    });

    this.ui.actions.append(actionsView.render().el);
  }

});
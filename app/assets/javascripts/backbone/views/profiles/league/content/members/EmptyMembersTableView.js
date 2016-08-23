BFApp.Views.EmptyMembersTableView = Marionette.CompositeView.extend({

  template: "backbone/templates/profiles/league/content/members/empty_members_table_view",

  className: "league-members-table empty-table",

  serializeData: function() {
    return {
      title: this.options.title == undefined ? "Members" : this.options.title
    }
  },
});
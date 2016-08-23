BFApp.Views.MembersTableView = Marionette.CompositeView.extend({

  itemView: BFApp.Views.MemberRowView,

  emptyView: BFApp.Views.MembersTableEmptyView,

  itemViewContainer: "tbody",

  template: "backbone/templates/profiles/league/content/members/members_table_view",

  className: "league-members-table",

  ui: {
    addNew: ".add-new-user"
  },

  events: {
    "click @ui.addNew": "clickedAddNew",
  },

  serializeData: function() {
    return {
      title: this.options.title,
      showAddNew: this.options.showAddNew
    }
  },

  clickedAddNew: function() {
    BFApp.vent.trigger("user:create");
  }

});
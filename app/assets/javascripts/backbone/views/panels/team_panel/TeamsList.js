BFApp.Views.TeamsList = Marionette.CompositeView.extend({

  template: "backbone/templates/panels/team_panel/team_list",
  className: "team-list",
  itemView: BFApp.Views.TeamRow,
  tagName:"ul",
  emptyView: BFApp.Views.TeamEmptyRow,
  
  appendHtml: function(collectionView, itemView, index) {
    collectionView.$el.append(itemView.el);
  }
  
});
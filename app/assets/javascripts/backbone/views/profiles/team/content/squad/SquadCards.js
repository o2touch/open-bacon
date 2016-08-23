BFApp.Views.SquadCards = Marionette.CompositeView.extend({
  template: "backbone/templates/profiles/team/content/squad/squad_panel_card_view",
  className: "squad-card clearfix",
  tagName: "ul",

  appendHtml: function(collectionView, itemView, index) {
    if (!itemView.model.get("id")) {
      collectionView.$el.prepend(itemView.el);
    } else {
      collectionView.$el.append(itemView.el);
    }
  }

});
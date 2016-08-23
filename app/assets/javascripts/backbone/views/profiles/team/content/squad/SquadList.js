BFApp.Views.SquadList = Marionette.CompositeView.extend({
  template: "backbone/templates/profiles/team/content/squad/squad_panel_list_view",
  className: "squad-list-collection",
  

  appendHtml: function(collectionView, itemView, index) {
    if (itemView.model.get("name")) {
      if (!itemView.model.get("id")) {
        collectionView.$el.find(".squad-list.new").removeClass("hide").append(itemView.el);
      } else if (itemView.model.isTeamOrganiser(ActiveApp.ProfileTeam)) {
        collectionView.$el.find(".squad-list.organiser").removeClass("hide").append(itemView.el);
      } else if (itemView.model.isRegistered()) {
        collectionView.$el.find(".squad-list.registered").removeClass("hide").append(itemView.el);
      } else if (!itemView.model.isRegistered()) {
        collectionView.$el.find(".squad-list.unregistered").removeClass("hide").append(itemView.el);
      }
    } else {
      collectionView.$el.find(".empty").removeClass("hide").append(itemView.el);
    }

  }

});
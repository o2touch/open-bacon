BFApp.Views.UsersListPanel = Marionette.CollectionView.extend({

  tagName: "ul",

  className: "users-list",

  itemView: BFApp.Views.UserRow,

  initialize: function(options) {
    this.listenTo(this.collection, "add remove fetch sync", this.render);
  },

});
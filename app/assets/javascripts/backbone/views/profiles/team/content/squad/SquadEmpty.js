BFApp.Views.SquadEmpty = Marionette.ItemView.extend({

  template: "backbone/templates/common/content/empty_tab",

  serializeData: function() {
    var title = "No players match your search";
    var msg = "";

    return {
      icon: "users",
      title: title,
      msg: msg
    };
  }

});
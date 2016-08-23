BFApp.Views.ResultsEmpty = Marionette.ItemView.extend({

  template: "backbone/templates/common/content/empty_tab",

  serializeData: function() {
    var title, msg;

    if (this.options.search) {
      title = "No past events match your search";
      msg = "";
    } else {
      if (this.options.isInTeam) {
        title = "Games and Events will appear here after they've finished";
        msg = "";
      } else {
        title = "No games have been played yet";
        msg = "";
      }
    }

    return {
      icon: "star",
      title: title,
      msg: msg
    };

  }

});
SearchApp.Controllers.Search = Marionette.Controller.extend({

  showSearch: function(options) {
    var layout = new SearchApp.Views.SearchLayout(options);
    SearchApp.content.show(layout);
  }

});
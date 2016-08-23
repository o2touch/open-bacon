var SearchApp = new Backbone.Marionette.Application();

// Namespacing
_.extend(SearchApp, {
  Controllers: {},
  Views: {}
});

// App Regions
SearchApp.addRegions({
  content: "#r-search-content"
});

SearchApp.addInitializer(function(options) {
  var searchController = new SearchApp.Controllers.Search();
  searchController.showSearch(options);
});
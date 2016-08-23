describe("BFApp.Views.SearchPanelLayout", function() {

  var layout;

  beforeEach(function() {
    // stub out that algolia shit
    var searchIndex = jasmine.createSpyObj('searchIndex', ['search']);
    var searchClient = jasmine.createSpyObj('searchClient', ['initIndex']);
    searchClient.initIndex.andReturn(searchIndex);
    spyOn(window, "AlgoliaSearch").andReturn(searchClient);

    layout = new BFApp.Views.SearchPanelLayout({
      location: new App.Modelss.Location(),
      context: "event"
    });
    layout.render();
  });

  afterEach(function() {
    layout = null;
  });

  it("shows the form and the welcome message", function() {
    expect(layout.$el).toContain("#search-input");
    expect(layout.$el).toContain("button[name=submit]");
    expect(layout.$el).toContain("#es-welcome-msg");
  });



  describe("submitting a search", function() {

    var searchLat = 21,
      searchLng = 53,
      resultLat = 22,
      resultLng = 54,
      eventTitle = "Some event title";

    beforeEach(function() {
      // we're already spying on layout.searchIndex.search
      layout.searchIndex.search.andCallFake(function(query, callback, params) {
        callback(true, {
          hits: [{
            _geoloc: {
              lat: resultLat,
              lng: resultLng
            },
            _rankingInfo: {
              geoDistance: 1
            },
            address: "Some nice address",
            title: eventTitle,
            time_local: "2014-05-29T22:40:00Z"
          }]
        });
      });

      spyOn(layout, "trigger");

      // here we emulate selecting a result from the google places dropdown, which populates this shared location model and then triggers a call to the layout's performSearch method
      layout.options.location.set({
        lat: searchLat,
        lng: searchLng
      });
      layout.performSearch();
    });

    it("triggers an ajax call to algolia with the right args", function() {
      var algoliaGeoParams = layout.searchIndex.search.mostRecentCall.args[2].aroundLatLng;
      expect(algoliaGeoParams.contains(searchLat)).toBe(true);
      expect(algoliaGeoParams.contains(searchLng)).toBe(true);
    });

    it("displays the results and triggers an event to update the map", function() {
      expect(layout.results.$el.find("ul.events .event-details")).toContainText(eventTitle);
      expect(layout.trigger.mostRecentCall.args[0]).toEqual("new:locations");
    });

  });

});
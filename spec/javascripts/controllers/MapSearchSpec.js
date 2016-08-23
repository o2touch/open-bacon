describe("BFApp.Controllers.MapSearch setup", function() {

  var controller, mapView, formView;

  beforeEach(function() {
    // have to hack on the main app regions here as we can't include both ABFApp.js and MapSearchApp.js as they both use the BFApp namespace
    BFApp.addRegions({
      map: "#r-map",
      searchPanel: "#r-search-panel"
    });

    // spy on all calls to region.show()
    spyOn(Marionette.Region.prototype, "show");

    formView = new Marionette.ItemView();
    spyOn(BFApp.Views, "SearchPanelLayout").andReturn(formView);

    mapView = new Marionette.ItemView();
    mapView.showMap = function() {};
    spyOn(BFApp.Views, "LocationEditMap").andReturn(mapView);

    controller = new BFApp.Controllers.MapSearch();
    controller.setup();

    spyOn(controller.mapView, "showMap");

    // fake the gmaps lib ready
    window.showMap();
  });

  it("instanciates and shows a new map view and search form view", function() {
    expect(BFApp.Views.SearchPanelLayout).toHaveBeenCalled();
    expect(Marionette.Region.prototype.show).toHaveBeenCalledWith(formView);

    expect(BFApp.Views.LocationEditMap).toHaveBeenCalled();
    expect(Marionette.Region.prototype.show).toHaveBeenCalledWith(mapView);

    expect(controller.mapView.showMap).toHaveBeenCalled();
  });

});
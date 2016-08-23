describe("BFApp.Views.EventCard", function() {

  var eventModel,
    eventCard,
    locationName = "Event location";

  beforeEach(function() {
    var locationModel = new App.Modelss.Location({
      title: locationName
    });

    eventModel = new App.Modelss.Event({
      title: "Event title",
      location: locationModel,
      time_local: "2014-04-02T16:45:03Z",
      game_type: 0,
      team: new App.Modelss.Team(),
      game_type_string: "game"
    });

    eventCard = new BFApp.Views.EventCard({
      model: eventModel
    });

    window.ActiveApp = {
      CurrentUser: new App.Modelss.User()
    };
  });

  it("displays the card with the correct information", function() {
    eventCard.render();
    expect(eventCard.$el.find("h1").text()).toEqual("Event title");
    expect(eventCard.$el.find(".location").text()).toEqual(locationName);
    expect(eventCard.$el.find("h2").text().trim()).toEqual("Wednesday, Apr 2nd 4:45pm");
  });

  it("updates the information when the model changes", function() {
    var newTitle = "New event title",
      newLocationName = "New event location";

    eventCard.render();
    eventModel.set("title", newTitle);
    eventModel.get("location").set("title", newLocationName);
    eventModel.set("time_local", "2015-03-08T12:25:14Z");

    expect(eventCard.$el.find("h1").text()).toEqual(newTitle);
    expect(eventCard.$el.find(".location").text()).toEqual(newLocationName);
    expect(eventCard.$el.find("h2").text().trim()).toEqual("Sunday, Mar 8th 12:25pm");
  });

});
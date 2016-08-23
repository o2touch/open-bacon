BFApp.Views.EventCard = Marionette.ItemView.extend({

  template: "backbone/templates/event/event_card",

  className: "event-card",

  ui: {
    joinButton: "button[name='join']"
  },

  initialize: function() {
    this.listenTo(this.model, "change", this.modelChange);
    this.currentLocation = this.model.get("location");
    if (this.currentLocation) {
      this.listenTo(this.currentLocation, "change", this.render);
    }
  },

  modelChange: function() {
    // if new location, start listening for changes
    var location = this.model.get("location");
    // when switch to new location object, we listen for changes
    // in this case, this only happens when we save a new location
    if (location && ("location" in this.model.changedAttributes())) {
      this.stopListening(this.currentLocation);
      this.currentLocation = location;
      this.listenTo(this.currentLocation, "change", this.render);
    }

    this.render();
  },

  serializeData: function() {
    var eventType = this.model.get("game_type_string");
    if (eventType === "event") {
      eventType = "other";
    }
    this.$el.addClass(eventType);

    var location = this.model.get("location"),
      locationString = (location) ? location.get("title") : "";

    // hack to get price in the event card quickly - this needs speccing properly - where do we want to see this?
    var price = this.model.getPriceString();
    if (price) {
      if (locationString) {
        locationString = " - " + locationString;
      }
      locationString = price + locationString;
    }

    var team = this.model.get("team");
    var date = this.model.getDateObj();

    return {
      title: this.model.get("title") || "Title",
      eventType: eventType,
      location: locationString,
      date: date.getMediumDate() + " " + date.getFormattedTime(),
      teamName: team.get("name"),
      teamUrl: team.getHref(),
      htmlPic: team.getPictureHtml("thumb")
    };
  }

});
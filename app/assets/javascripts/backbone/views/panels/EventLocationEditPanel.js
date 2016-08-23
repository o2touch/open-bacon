/**
 * This is used on the Event page
 */
BFApp.Views.EventLocationEditPanel = Marionette.ItemView.extend({

  template: "backbone/templates/panels/event_location_edit_panel",

  tagName: "form",

  className: "classic",

  events: {
    "keyup #edit-location": "syncLocation",
    "click .close-panel": "onBeforeCancel",
    "click button[name='save']": "save"
  },

  ui: {
    locationInput: "#edit-location",
    saveButton: "button[name='save']",
    locationMap: ".location-map-container"
  },

  initialize: function() {
    this.model.store();

    if (!this.model.get("location")) {
      var newLocation = new App.Modelss.Location({
        title: ""
      });
      this.model.set("location", newLocation);
    }
  },

  serializeData: function() {
    return {
      location: this.model.get("location").get("title")
    };
  },

  compareData: function() {
    var storedLocation = this.model.storedAttributes.location;
    var storedTitle = (storedLocation) ? storedLocation.title : "";
    if (this.ui.locationInput.val() == storedTitle) {
      this.ui.saveButton.prop("disabled", true);
    } else {
      this.ui.saveButton.prop("disabled", false);
    }
  },

  syncLocation: function() {
    var title = this.ui.locationInput.val();
    this.model.get("location").setFromString(title);
    this.compareData();
  },

  onBeforeCancel: function() {
    this.model.restore();
    this.trigger("dismiss");
    return false;
  },

  onRender: function() {
    this.mapView = new BFApp.Views.LocationEditMap({
      model: this.model,
      isDraggable: true,
      isEditLocation: true
    });
    this.ui.locationMap.append(this.mapView.render().el);
  },

  onShow: function() {
    this.mapView.showMap();
    this.compareData();
  },

  save: function() {
    var that = this;
    disableButton(this.ui.saveButton);

    var attrs = {
      location: this.model.getSaveLocation()
    };

    this.model.save(attrs, {
      success: function(model, response, options) {
        enableButton(that.ui.saveButton);
        that.trigger("dismiss");
      },
      error: function(model, response, options) {
        errorHandler({
          button: that.ui.saveButton
        });
      },
      notify: 1
    });
    return false;
  }

});
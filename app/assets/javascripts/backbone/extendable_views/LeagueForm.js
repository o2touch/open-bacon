BFApp.Views.LeagueForm = Marionette.Layout.extend({

  template: "backbone/templates/common/form/league_form",

  tagName: "form",

  className: "league-form",

  ui: {
    uploadButton: "[name=upload-button]",
    fileInput: "input[name=logo]",
    thumb: ".pfl-pic-section img",

    titleInput: "input[name=title]",
    locationTitle: "input[name=location]",
    locationSearch: "button[name=location-search]",

    saveButton: "button[name=save]"
  },

  events: {
    "keyup #edit-location": "syncLocation",
    "click @ui.locationSearch": "locationSearch",
    "submit": "save"
  },

  regions: {
    locationMap: "#mapwrapper",
  },

  initialize: function(options) {
    this.isEdit = !this.model.isNew();

    // store the current state of the model, so we can restore it on cancel
    if (this.isEdit) {
      this.model.store();
    }
  },

  serializeData: function() {
    return {
      formTitle: this.options.title,

      htmlPic: this.model.getPictureHtml("small"),
      title: this.model.get("title"),
      locationTitle: this.model.get("location").get("title"),

      isEdit: this.isEdit,
      isMitoo: (ActiveApp.Tenant.get("name") == "mitoo")
    };
  },

  onRender: function() {
    if (this.isEdit) {
      this.bindPictureUploader();
    }

    this.mapView = new BFApp.Views.LocationEditMap({
      // NOTE: here we send the event instead of the location obj, this is because the location obj may get replaced by another, so we need a reference to it instead of just the obj itself
      model: this.model,
      isDraggable: true,
      isEditLocation: true
    });
    this.locationMap.show(this.mapView);

    this.listenTo(this.mapView, "geocoded:location", function() {
      enableButton(this.ui.locationSearch);
    });
  },

  onShow: function() {
    this.mapView.showMap();
  },

  bindPictureUploader: function() {
    var action = '/leagues/' + this.model.get("id") + '/upload_image';
    initFileUploader(this.ui.uploadButton, this.ui.thumb, action, this.model);
  },

  syncLocation: function() {
    var title = this.ui.locationTitle.val();
    this.model.get("location").setFromString(title);
  },

  locationSearch: function() {
    var isValid = BFApp.validation.validateInput({
      htmlObject: this.ui.locationTitle,
      require: true,
      requireMessage: false
    });

    if (isValid) {
      disableButton(this.ui.locationSearch);

      this.mapView.performGeocode({
        address: this.ui.locationTitle.val()
      }, false);
    }
  },

  save: function(e) {
    e.preventDefault();
    var that = this;

    if (this.validateSave()) {
      disableButton(this.ui.saveButton);

      var params = this.getCustomParams();
      // common params
      params.title = this.ui.titleInput.val();
      if (!this.isEdit) {
        params.tenant_id = ActiveApp.Tenant.get("id");
      }

      this.model.save(params, {
        success: function(model) {
          if (that.isEdit) {
            that.saveSuccess = true;
            BFApp.vent.trigger("popup:close");
          } else {
            window.location.href = "/leagues/" + model.get("slug");
          }
        },
        error: function() {
          errorHandler({
            button: that.ui.saveButton
          });
        }
      });
    }
  },

  onClose: function() {
    if (this.saveSuccess) {
      this.model.removeStore();
    } else {
      this.model.restore();
    }
  },


  /**
   * Overrides
   */

  validateSave: function() {
    var isTitle = BFApp.validation.isTitle({
      require: true,
      htmlObject: this.ui.titleInput
    });
    var isLocation = BFApp.validation.isLocation({
      require: true,
      htmlObject: this.ui.locationTitle,
      model: this.model.get("location")
    });
    return (isTitle && isLocation);
  },

  getCustomParams: function() {
    return {};
  }

});
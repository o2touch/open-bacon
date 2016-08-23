BFApp.Views.CreateDivisionForm = Marionette.ItemView.extend({

  tagName: "form",

  template: 'backbone/templates/popups/create_division_form',

  className: "text-popup create-division-form",

  ui: {
    titleInput: "[name=title]",
    startDateInput: "[name=start]",
    endDateInput: "[name=end]",
    ageGroup: "[name=age_group]",
    submitButton: "[name=submit]"
  },

  events: {
    "click @ui.submitButton": "createDivision"
  },

  validateForm: function() {
    var isTitle = BFApp.validation.isTitle({
      require: true,
      htmlObject: this.ui.titleInput
    });
    return (isTitle);
  },

  createDivision: function(e) {
    e.preventDefault();
    var that = this;

    if (this.validateForm()) {
      disableButton(this.ui.submitButton);

      var attrs = {
        title: this.ui.titleInput.val(),
        age_group: this.ui.ageGroup.filter(":checked").val()
      };
      var startDate = this.ui.startDateInput.val();
      if (startDate) {
        attrs.start_date = moment(startDate, "ddd MMM DD YYYY").toCustomISO();
      }
      var endDate = this.ui.endDateInput.val();
      if (endDate) {
        attrs.end_date = moment(endDate, "ddd MMM DD YYYY").toCustomISO();
      }

      var division = new App.Modelss.Division(attrs);
      division.saveToLeague(this.options.league.get("id"), {
        success: function(model) {
          window.location.href = "/leagues/" + that.options.league.get("slug") + "/divisions/" + model.get("id");
        },
        error: function() {
          errorHandler({
            button: that.ui.submitButton
          });
        }
      });
    }
  },

  onShow: function() {
    this.ui.startDateInput.glDatePicker({
      hideOnClick: true,
      selectedDate: moment().toDate(),
      dowOffset: (ActiveApp.CurrentUser.get("country") == "US") ? 0 : 1,
      onClick: (function(el, cell, date, data) {
        el.val(date.toDateString());
      }),
      selectableDateRange: null // override
    });

    this.ui.endDateInput.glDatePicker({
      hideOnClick: true,
      selectedDate: moment().toDate(),
      dowOffset: (ActiveApp.CurrentUser.get("country") == "US") ? 0 : 1,
      onClick: (function(el, cell, date, data) {
        el.val(date.toDateString());
      }),
      selectableDateRange: null // override
    });
  }

});
BFApp.Views.TeamForm = Marionette.ItemView.extend({

  template: "backbone/templates/common/form/team_form",

  tagName: "form",

  ui: {
    teamName: "input[name=name]",
    ageGroup: "input[name=age_group]",
    cancelLink: "a[name=cancel]",
    saveButton: "button[name=save]",
    uploadButton: "[name=upload-button]",
    fileInput: "input[name=team-profile-picture]",
    thumb: ".pfl-pic-section img"
  },

  events: {
    "submit": "save",
    "change input[name=name]": "syncName",
    "change input[name=age_group]": "syncAge"
  },

  triggers: {
    "click .cancel-link": "team:edit:cancel"
  },

  removedElements: [],

  serializeData: function() {
    var data = this.getCustomSerializeData();

    data.title = this.options.title;
    data.msg = this.options.msg;
    data.htmlPic = this.model.getPictureHtml("small");
    data.name = this.model.get("name");
    data.edit = (this.options.type == "edit");

    return data;
  },

  /**
   * sync shit to the model so it persists if they change to another tenant form
   */

  syncName: function() {
    this.model.set("name", this.ui.teamName.val());
  },

  syncAge: function() {
    var selectedAge = this.ui.ageGroup.filter(":checked");
    if (selectedAge.length) {
      this.model.set("age_group", selectedAge.val());
    }
  },

  save: function(e) {
    e.preventDefault();
    var that = this;

    if (this.validateSave()) {
      disableButton(this.ui.saveButton);

      var params = this.getCustomParams();
      // common params
      params.name = this.ui.teamName.val();
      params.age_group = this.ui.ageGroup.filter(":checked").val();

      if (this.options.noSave) {
        this.model.set(params);
        this.trigger("team:set", this.ui.saveButton);
      } else {
        var saveOptions = {
          success: function(model) {
            if (that.options.goToTeamPage) {
              window.location.href = "/teams/" + model.get("id");
            } else {
              that.trigger("team:saved", model);
              if (that.options.type == "edit") {
                $(".css-reload.team-theme").prop("href", $(".css-reload.team-theme").prop("href"))
              }
            }
          },
          error: function(m, r) {
            errorHandler({
              button: that.ui.saveButton
            });
          }
        }

        if (this.options.context == "league_admin") {
          saveOptions.division_season = this.options.division_season;
        }

        this.model.save(params, saveOptions);
      }
    }
  },

  formInit: function() {
    this.customFormInit();

    if (this.model.get("age_group")) {
      this.ui.ageGroup.filter("[value=" + this.model.get("age_group") + "]").prop("checked", true);
    }

    // Remove elements for league admins
    if (this.options.context == "league_admin") {
      this.$(".age-group").hide(); // Should really use removeFormField
    }

  },

  onRender: function() {
    this.formInit();
    if (this.options.type == "edit") {
      this.bindPictureUploader();
    }
    this.customOnRender();

    this.$('input, textarea').placeholder();
  },

  bindPictureUploader: function() {
    var action = '/teams/' + this.model.get("id") + '/upload_profile_picture';
    initFileUploader(this.ui.uploadButton, this.ui.thumb, action, this.model);
  },

  removeFormField: function(ele) {

    var eleId = ele.attr('id');
    ele.addClass("hide");
    this.$("label[for=" + eleId + "]").addClass("hide");

    this.removedElements.push(ele);
  },

  isRemovedFormField: function(ele) {
    var isRemoved = _.find(this.removedElements, function(e) {
      return (e == ele);
    });
    return isRemoved;
  },

  /**
   * Overrides
   */

  getCustomSerializeData: function() {
    return {
      bottomFieldsHtml: ""
    };
  },

  customFormInit: function() {
    // nothing
  },

  customOnRender: function() {
    // nothing
  },

  validateSave: function() {
    return true;
  },

  getCustomParams: function() {
    return {};
  }


});
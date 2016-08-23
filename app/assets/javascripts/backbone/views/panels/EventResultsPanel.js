BFApp.Views.EventResultsPanel = Marionette.ItemView.extend({

  tagName: "div",

  template: "backbone/templates/panels/event_results_panel",

  events: {
    "click .save": "submitScore",
    "click .edit-score": "editScore",
  },

  editScore: function() {
    this.$(".score, .edit-score").addClass("hide");
    this.$("form").removeClass("hide");
  },

  serializeData: function() {
    return {
      scoreFor: this.model.get("score_for"),
      scoreAgainst: this.model.get("score_against")
    }
  },

  submitScore: function() {
    var that = this;
    var scoreFor = this.$(".score-for");
    var scoreAgainst = this.$(".score-against");

    if (this.model.validateScore(scoreFor, scoreAgainst)) {

      disableButton(this.$(".save"));

      var attributes = {
        score_for: scoreFor.val(),
        score_against: scoreAgainst.val()
      };

      this.model.save(attributes, {
        success: function(model, response, options) {
          that.render();
        },
        error: function(model, response, options) {
          errorHandler({
            button: that.$(".save")
          });
        }
      });
    }

    return false;
  },

  onRender: function() {
    this.$("input, textarea").placeholder();
  }


});
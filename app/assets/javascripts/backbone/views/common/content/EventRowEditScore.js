BFApp.Views.EventRowEditScore = Marionette.ItemView.extend({

  template: 'backbone/templates/common/content/event_row_edit_score',
  className: 'event-row-edit-score',

  ui: {
    'form': 'form.popover',
    'homeScore': '.score-for',
    'awayScore': '.score-against',
    'saveButton': '.save',
    'editIcon': '.edit-score',
    'alertBox': '.alert-box',
    'closeScore': '.close-score'
  },

  events: {
    "submit @ui.form": "submitScore",
    "click @ui.editIcon": "editScore",
    "click @ui.saveButton": "submitScore",
    "click @ui.closeScore": "hidePopup"
  },


  serializeData: function() {
    return {
      score: {
        home: (this.model.get('score_for')) ? this.model.get('score_for') : '',
        away: (this.model.get('score_against')) ? this.model.get('score_against') : ''
      }
    };
  },


  hidePopup: function() {
    this.ui.form.addClass('hide');
    return false;
  },

  editScore: function() {
    $('.event-row-edit-score form.popover').addClass('hide');
    this.ui.form.removeClass('hide');
    return false;
  },

  submitScore: function(e) {
    e.preventDefault();
    var that = this;
    this.ui.alertBox.remove();

    if ($.trim(this.ui.homeScore.val()) == '' && $.trim(this.ui.awayScore.val()) == '' && !this.model.get('score_for') && !this.model.get('score_against')) return this.hidePopup();

    if (this.model.validateScore(this.ui.homeScore, this.ui.awayScore)) {
      disableButton(this.ui.saveButton);
      this.model.save({
        score_for: this.ui.homeScore.val(),
        score_against: this.ui.awayScore.val()
      }, {
        success: function(model, response, options) {
          // that.render();
        },
      });
    }
  }

});
BFApp.Views.EventRow = Marionette.ItemView.extend({

  template: 'backbone/templates/common/content/event_row',

  tagName: 'div',

  className: 'event-row',

  modelEvents: {
    'change': 'render'
  },

  onRender: function() {
    // add score class for css layout purpose
    if (this.model.get('score_for') && this.model.get('score_against')) this.$el.addClass('with-score');

    // Add game type class for css color purpose
    this.$el.addClass('event-type-' + this.model.get('game_type_string'));

    // Use for other extended views (resultRow)
    this.customRender();

    this.flash();
  },

  flash: function() {
    this.$el.css({
      "opacity": "0"
    });
    this.$el.animate({
      "opacity": "1"
    }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
  },

  serializeData: function() {
    var timeObject = this.model.getDateObj();

    // Added a default colour here because we were getting a bug where there was no team model being returned - PR
    var color = '1d2968';
    if (this.model.get('team')!=null) {
      color = this.model.get('game_type_string') == 'game' && this.model.get('team').get('colour1')
    }

    var data = {
      // Event information
      date: timeObject.date(),
      month: timeObject.format('MMM'),
      extraEventDetails: false,

      // Event status
      cancelled: (this.model.get("status") == 1),
      postponed: (this.model.get("status") == 3),

      // event score
      score: {
        home: (this.model.get('score_for')) ? this.model.get('score_for') : false,
        away: (this.model.get('score_against')) ? this.model.get('score_against') : false,
      },

      // Styling purpose
      color: color
    };

    this.customSerializeData(data);

    return data;
  },



  /**
   * these can be overridden
   */

  customRender: function() {
    // do nothing
  },

  customSerializeData: function(data) {
    var timeObject = this.model.getDateObj();

    data.title = this.model.get('title');
    data.location = this.model.getLocationTitle();
    data.time = (this.model.get('time_tbc')) ? 'Time TBC' : timeObject.getFormattedTime();
    data.href = this.model.getHref();
    data.linkNewTab = false;
  }

});
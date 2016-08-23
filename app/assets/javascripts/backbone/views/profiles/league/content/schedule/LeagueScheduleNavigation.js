BFApp.Views.LeagueScheduleNavigation = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/league/content/schedule/league_schedule_navigation",

  events: {
    "keyup .schedule-search": "searchChange",
    "click .schedule-search-close": "clearSearch"
  },

  ui: {
    "search": ".schedule-search",
    "searchReset": ".schedule-search-close"
  },

  serializeData: function() {
    // only show search if >3 events
    return {
      showSearch: (this.collection.length > 1)
    };
  },  

  clearSearch: function() {
    this.ui.search.val('').keyup();
    return false;
  },

  searchChange: function(e) {
    if (keyIsCharacter(e.keyCode)) {
      this.trigger("fixture:filter");
      if (this.ui.search.val()=="") {
        this.ui.searchReset.addClass("hide");
      } else {
        this.ui.searchReset.removeClass("hide");
      }
    }
  },

  onRender: function() {
    this.$("input, textarea").placeholder();
  }

});
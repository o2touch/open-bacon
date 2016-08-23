BFApp.Views.LeagueRegistrationView = Marionette.CompositeView.extend({

  template: "backbone/templates/profiles/league/content/teams/league_registration_view",

  className: "league-registration",

  ui: {
    open: "a#open",
    close: "a#close",
  },

  events: {
    "click @ui.open": "clickedOpen",
    "click @ui.close": "clickedClose"
  },

  initialize: function(options) {
    this.division = options.division;

    this.listenTo(this.division, "change", this.render);
  },

  onRender: function() {
    if (this.division.isRegistrationOpen()) {
      this.$(".open").removeClass("hide");
      this.$(".closed").addClass("hide");
    } else {
      this.$(".closed").removeClass("hide");
      this.$(".open").addClass("hide");
    }
  },

  serializeData: function() {
    return {
      title: this.options.title == undefined ? "Teams" : this.options.title
    }
  },

  clickedOpen: function() {
    this.division.openRegistration();
  },

  clickedClose: function() {
    this.division.closeRegistration();
  }

});
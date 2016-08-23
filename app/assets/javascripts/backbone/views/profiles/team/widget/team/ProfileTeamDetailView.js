BFApp.Views.ProfileTeamDetailView = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/widget/team/team_detail_view",

  className: "team-profile-details",

  initialize: function() {
    ActiveApp.ProfileTeam.bind("change", _.bind(this.render, this));
  },

  triggers: {
    "click #btn-edit-profile": "show:edit"
  },

  onRender: function() {
    var className = convertSportCss(this.model.get('sport')) + '-icon';
    this.$el.addClass('sport-icon ' + className);
    $('#refresh-css').prop('href', $('#refresh-css').prop('href'));
  },

  serializeData: function() {
    return {
      htmlPic: this.model.getPictureHtml("medium"),
      name: this.model.get("name"),
      leagueModel: (this.model.get("league")) ? this.model.get("league") : null,
      division: (this.model.get("division")) ? this.model.get("division") : null,
      leagueName: this.model.get("league_name"),
      canUpdateTeam: ActiveApp.Permissions.get("canUpdateTeam")
    };
  }

});
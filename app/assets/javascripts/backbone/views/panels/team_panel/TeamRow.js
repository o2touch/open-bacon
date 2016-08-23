BFApp.Views.TeamRow = Marionette.ItemView.extend({

  tagName: "li",
  template: "backbone/templates/panels/team_panel/team_row",

  serializeData: function() {
    return {
      htmlPic: this.model.getPictureHtml("thumb"),
      colour1: this.model.get("colour1"),
      colour2: this.model.get("colour2"),
      name: this.model.get("name"),
      url: this.model.getHref(),
      textColor: (BFColor.getLuminosity('#' + this.model.get("colour1")) > 190) ? "black" : "white"
    };
  },

  onRender: function() {
    var className = convertSportCss(this.model.get('sport')) + '-icon';
    this.$('.team-element').addClass(className);
  }

});
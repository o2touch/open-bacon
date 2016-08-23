BFApp.Views.ClubPanel = Marionette.Layout.extend({

  template: "backbone/templates/panels/club_panel",

  serializeData: function() {
    var location = this.model.get("location");
    return {
      logo: this.model.get("profile_picture_small_url"),
      name: this.model.get("name"),
      addressTitle: (location && location.title) ? location.title : ""
    };
  },

});
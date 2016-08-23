BFApp.Views.SquadCardItem = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_panel_card",

  tagName: "li",

  className: "squad-player columns mobile-four four",

  events: {
    "click .squad-player-container": "active"
  },

  initialize: function() {
    // only thing that can change that is displayed is the name
    this.listenTo(this.model, "change:name", this.updateName);
  },

  active: function() {
    $(".squad-player-container").removeClass("active");
    this.$(".squad-player-container").addClass("active");
  },

  serializeData: function() {
    return {
      newItem: this.model.isNew(),
      profile_pic: this.model.get("profile_picture_large_url"),
      id: this.model.get("id")
    };
  },

  onRender: function() {
    this.updateName();
  },

  updateName: function() {
    var name = this.model.get("name");
    if (!name && this.model.isNew()) {
      name = "New player";
    }
    this.$el.find(".squad-player-name").text(name);
  }

});
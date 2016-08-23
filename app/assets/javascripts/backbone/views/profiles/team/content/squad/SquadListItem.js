BFApp.Views.SquadListItem = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_panel_list_item",

  tagName: "li",

  className: "squad-player",

  events: {
    "click .player-list-item": "active"
  },

  initialize: function() {
    // only things that can change that are displayed are: name and team roles
    this.listenTo(this.model, "change:name", this.updateName);
    this.listenTo(this.model.get("team_roles"), "add destroy", this.render);
  },

  active: function() {
    $(".player-list-item").removeClass("active");
    this.$(".player-list-item").addClass("active");
  },

  serializeData: function() {
    return {
      newItem: this.model.isNew(),
      isRegistered: this.model.isRegistered(),
      profilePicHtml: this.model.getPictureHtml("thumb"),
      id: this.model.get("id"),
      isOrganiser: this.model.isTeamOrganiser(ActiveApp.ProfileTeam)
    };
  },

  onRender: function() {
    this.updateName();
    this.$el.find(".star").tipsy({
      gravity: 's'
    });
  },

  updateName: function() {
    var name = this.model.get("name");
    if (!name && this.model.isNew()) {
      name = "New player";
    }
    this.$el.find(".squad-name-inner").text(name);
  }

});
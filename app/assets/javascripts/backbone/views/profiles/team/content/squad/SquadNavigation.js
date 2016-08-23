BFApp.Views.SquadNavigation = Marionette.ItemView.extend({
  template: "backbone/templates/profiles/team/content/squad/squad_navigation",
  tagName: "div",
  className: "squad-navigation clearfix",

  events: {
    "click .navigation-link a": "navigation",
    "keyup .squad-search": "searchChanged",
    "click .clear-squad-search-button": "clearSearch",
    "click .view-link": "changeView"
  },

  triggers: {
    "click button[title='invite player']": "invite-player:clicked"
  },

  ui: {
    "all": "a[title='all']",
    "players": "a[title='players']",
    "organiser": "a[title='organisers']",
    "parents": "a[title='parents']",
    "searchInput": ".squad-search",
    "listView": "a[title='list-view']",
    "cardView": "a[title='card-view']"
  },


  initialize: function() {
    var that = this;
    BFApp.vent.on("squad:toggle:demo", function() {
      var disableAddPlayers = ActiveApp.Teammates.hasDemoPlayers();
      that.$("button[title='invite player']").prop("disabled", disableAddPlayers);
    });
  },

  serializeData: function() {
    return {
      canManageRoster: ActiveApp.Permissions.get("canManageRoster"),
      disable: ActiveApp.Teammates.hasDemoPlayers()
    };
  },



  navigation: function(e) {
    if (!$(e.currentTarget).hasClass("active") && !$(e.currentTarget).hasClass("disabled")) {
      this.$(".navigation-link a").removeClass("active");
      $(e.currentTarget).addClass("active");
      this.trigger($(e.currentTarget).attr("title") + ":clicked");
    }
    return false;
  },

  clearSearch: function() {
    this.$(".squad-search").val('');
    this.$(".squad-search").keyup();
    return false;
  },

  changeView: function(e) {
    if (!$(e.currentTarget).hasClass("active")) {
      this.$(".view-link").removeClass("active");
      $(e.currentTarget).addClass("active");
      this.trigger($(e.currentTarget).attr("title") + ":clicked");
    }
    return false;
  },

  searchChanged: function(element) {
    if (keyIsCharacter(element.keyCode)) {
      this.trigger("squad-search:changed");
      var clearSearchButton = this.$('.clear-squad-search-button');
      if (element.currentTarget.value === '') {
        clearSearchButton.addClass('hide');
      } else {
        clearSearchButton.removeClass('hide');
      }
    }
  },

  onRender: function() {
    // make placeholders work in shit browsers
    this.$('input, textarea').placeholder();
  },


});
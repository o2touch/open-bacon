BFApp.Views.SquadTab = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_tab",
  className: "squad-tab clearfix",

  displayMode: "card",
  navigationOn: "all",


  regions: {
    navigation: "#r-squad-navigation",
    controls: "#r-squad-controls",
    notice: "#r-squad-notice",
    players: "#r-squad-list"
  },

  events: {
    "click .player-list-item": "viewPlayer",
    "click .squad-player-container": "viewPlayer"
  },

  initialize: function() {
    this.displayMode = this.options.displayMode;
    this.listenTo(this.collection, "change add remove reset", this.updateCollection, this);
    this.listenTo(ActiveApp.ProfileTeam, "change", this.updateCollection, this);

    this.sidebar = this.options.mainLayout.squadInformation;
  },

  viewPlayer: function(e) {
    var that = this;


    if ($(e.currentTarget).hasClass("new")) {
      this.addPlayerForm();
    } else {
      var playerId = $(e.currentTarget).attr("data-id");
      var playerModel = this.collection.get("user" + playerId);

      this.SquadPlayerView = new BFApp.Views.SquadPlayer({
        model: playerModel
      });

      this.sidebar.show(this.SquadPlayerView);

      this.SquadPlayerView.on("remove:player", function() {
        that.onBoarding();
      });

      this.SquadPlayerView.on("add:parent", function(model) {
        that.squadFormView = new BFApp.Views.SquadForm({
          model: model,
          secondParent: true
        });
        that.listenTo(ActiveApp.ProfileTeam, "change", that.squadFormView.render);

        that.squadFormView.on("add-player", function() {
          that.onBoarding();
        });

        that.sidebar.show(that.squadFormView);
      });



      this.SquadPlayerView.on("permissions:changes", function() {
        that.updateCollection();
      });
    }
  },

  onRender: function() {
    var that = this;

    /* Navigation */
    this.navigationView = new BFApp.Views.SquadNavigation();

    this.navigation.show(this.navigationView);

    this.navigationView.on("all:clicked", function() {
      that.navigationOn = "all";
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("parents:clicked", function() {
      that.navigationOn = "parents";
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("players:clicked", function() {
      that.navigationOn = "players";
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("organisers:clicked", function() {
      that.navigationOn = "organisers";
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("squad-search:changed", function() {
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("list-view:clicked", function() {
      that.displayMode = "list";
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("card-view:clicked", function() {
      that.displayMode = "card";
      that.updateCollection();
      that.onBoarding();
    });

    this.navigationView.on("invite-player:clicked", function() {
      that.addPlayerForm();
    });

    /* Update collection & sidebarView */
    this.updateCollection();
    this.onBoarding();

  },

  /* Onboarding */
  onBoarding: function() {
    var sidebarLayout;
    if (ActiveApp.Permissions.get("canManageRoster") && ActiveApp.CurrentUser.isLoggedIn()) {
      sidebarLayout = new BFApp.Views.SquadAddPlayerControl();
      var that = this;
      sidebarLayout.on("add-player:clicked", function() {
        that.addPlayerForm();
      });
    } else {
      sidebarLayout = new BFApp.Views.SquadOnboarding();
    }

    this.sidebar.show(sidebarLayout);
  },


  /* Add new player */
  addNewPlayer: function() {
    this.navigationOn = "all";
    this.navigationView.$(".navigation-link a").removeClass("active");
    this.navigationView.$("a[title='all']").addClass("active").removeClass("disabled");

    this.fakePlayer = new App.Modelss.User({
      name: "",
      email: "",
      mobile_number: ""
    });

    this.allCollection.add(this.fakePlayer);
    this.currentCollection = this.allCollection;

    this.updateView();
  },

  /* Add player Form */
  addPlayerForm: function() {
    var that = this;

    if (!this.fakePlayer) {
      this.addNewPlayer();
    }

    this.squadFormView = new BFApp.Views.SquadForm({
      model: that.fakePlayer
    });

    this.squadFormView.on("cancel:clicked", function() {
      that.fakePlayer = null;
      that.onBoarding();
      that.updateCollection();
    });

    this.squadFormView.on("add-player", function() {
      that.fakePlayer = null;
      that.addPlayerForm();
      that.updateCollection();
    });

    $(".player-list-item, .squad-player-container").removeClass("active");
    $(".player-list-item.new, .squad-player-container.new").addClass("active");
    that.sidebar.show(this.squadFormView);

  },

  updateCollection: function() {
    var that = this;

    //get current search
    this.searchText = this.navigationView.ui.searchInput.val();

    //update all collection     
    this.allCollection = new App.Collections.Users(that.collection.filter(function(user) {
      return user.isPlayer(ActiveApp.ProfileTeam) && matchSearch(that.searchText, user.get('name'));
    }));

    this.parentsCollection = new App.Collections.Users(that.collection.filter(function(user) {
      return user.isTeamParent(ActiveApp.ProfileTeam) && matchSearch(that.searchText, user.get('name'));
    }));

    this.organisersCollection = new App.Collections.Users(that.collection.filter(function(user) {
      return user.isTeamOrganiser(ActiveApp.ProfileTeam) && matchSearch(that.searchText, user.get('name'));
    }));

    this.playersCollection = new App.Collections.Users(that.collection.filter(function(user) {
      return user.isPlayer(ActiveApp.ProfileTeam) && matchSearch(that.searchText, user.get('name'));
    }));

    //assign the current one 
    if (this.navigationOn == "all") {
      this.currentCollection = this.allCollection;
    } else if (this.navigationOn == "organisers") {
      this.currentCollection = this.organisersCollection;
    } else if (this.navigationOn == "parents") {
      this.currentCollection = this.parentsCollection;
    } else if (this.navigationOn == "players") {
      this.currentCollection = this.playersCollection;
    }

    if (this.allCollection.length == 0 && this.parentsCollection.length == 0 ||  this.allCollection.length == 0 && this.navigationOn == "all") {
      this.currentCollection = this.organisersCollection;
      this.navigationView.ui.organiser.addClass("active")
    }

    this.updateView();

  },

  updateView: function() {
    var that = this;

    //update card view
    this.playerCardsView = new BFApp.Views.SquadCards({
      collection: that.currentCollection,
      itemView: BFApp.Views.SquadCardItem,
      emptyView: BFApp.Views.SquadEmpty
    });

    //update list view
    this.playerListView = new BFApp.Views.SquadList({
      collection: that.currentCollection,
      itemView: BFApp.Views.SquadListItem,
      emptyView: BFApp.Views.SquadEmpty
    });

    //add Length information in navigation
    this.navigationView.ui.all.find("span").text("(" + that.allCollection.length + ")");
    this.navigationView.ui.players.find("span").text("(" + that.playersCollection.length + ")");
    this.navigationView.ui.organiser.find("span").text("(" + that.organisersCollection.length + ")");
    this.navigationView.ui.parents.find("span").text("(" + that.parentsCollection.length + ")");

    if (that.allCollection.length === 0) {
      this.navigationView.ui.all.addClass("disabled").removeClass("active");
    } else {
      this.navigationView.ui.all.removeClass("disabled");
    }

    if (that.parentsCollection.length === 0) {
      this.navigationView.ui.parents.addClass("disabled").removeClass("active");
    } else {
      this.navigationView.ui.parents.removeClass("disabled");
    }

    if (!ActiveApp.ProfileTeam.isJuniorTeam()) {
      this.navigationView.ui.parents.addClass("hide");
    } else {
      this.navigationView.ui.parents.removeClass("hide");
    }

    //Display view
    if (this.displayMode == "card") {
      this.players.show(this.playerCardsView);
    } else if (this.displayMode == "list") {
      this.players.show(this.playerListView);
    }
  }

});
BFApp.Views.SquadPlayer = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/content/squad/squad_player/squad_player",
  className: "squad-player clearfix",

  ui: {
    secondParents: "#r-player-second-parent"
  },

  regions: {
    head: "#r-player-profile",
    contact: "#r-player-contact",
    parents: "#r-player-parent",
    secondParents: "#r-player-second-parent",
    children: "#r-player-children",
    permission: "#r-player-permission",
    actions: "#r-player-actions"
  },

  events: {
    "click .add-second-parent": "addSecondParent"
  },

  addSecondParent: function() {
    // SHOW SOME FORM
    this.trigger("add:parent", this.model);
  },

  initialize: function() {
    this.originalPlayerName = this.model.get("name");
  },

  serializeData: function() {
    return {
      isRegistered: this.model.isRegistered(),
      currentUserCanManageTeam: ActiveApp.Permissions.get("canManageTeam"),
      isJunior: this.model.get("junior")
    };
  },

  onRender: function() {

    /* User permission */
    var isRegistered = this.model.isRegistered();
    var isCurrentUser = (this.model.get("id") == ActiveApp.CurrentUser.get("id"));
    var currentUserCanManageTeam = ActiveApp.Permissions.get("canManageTeam");

    var isJunior = this.model.isJunior();
    var isParent = this.model.isParent();


    /* player header */
    var playerProfile = new BFApp.Views.SquadPlayerProfile({
      model: this.model
    });
    this.head.show(playerProfile);


    /* Juionr display parents contacts informations */
    if (isJunior) {
      var parents = this.model.getParents(ActiveApp.Teammates);

      /* first Parents */
      var playerParents = new BFApp.Views.SquadPlayerParents({
        model: parents.models[0]
      });

      this.parents.show(playerParents);

      /* second Parents */
      if (parents.length > 1) {
        this.ui.secondParents.removeClass("hide");
        var secondParents = new BFApp.Views.SquadPlayerParents({
          model: parents.models[1]
        });
        this.secondParents.show(secondParents);
      }
      /* Adult display own contact informations */
    } else {
      /* player contact */
      var playerContact = new BFApp.Views.SquadPlayerContact({
        model: this.model
      });
      this.contact.show(playerContact);
    }

    /* Parents player display list of children */
    if (isParent) {
      var children = this.model.getChildrens(ActiveApp.Teammates);
      if (children.length > 0) {
        var playerChildren = new BFApp.Views.SquadPlayerChildren({
          model: this.model,
          children: this.model.getChildrens(ActiveApp.Teammates)
        });
        this.children.show(playerChildren);
      }
    }

    /* player permission */
    if (currentUserCanManageTeam && !isCurrentUser && isRegistered && !isJunior) {
      var playerPermission = new BFApp.Views.SquadPlayerPermission({
        model: this.model
      });
      this.permission.show(playerPermission);
    }

    /* player actions */
    if (currentUserCanManageTeam && !isCurrentUser) {
      var playerActions = new BFApp.Views.SquadPlayerActions({
        model: this.model
      });
      this.actions.show(playerActions);
      var that = this;
      playerActions.on("remove:player", function() {
        that.trigger("remove:player");
      });
    }
  }

});
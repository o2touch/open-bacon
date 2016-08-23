BFApp.Views.LeagueMembersLayout = Marionette.Layout.extend({

  template: "backbone/templates/profiles/league/content/members/league_members_layout",

  regions: {
    active: "#r-active-members",
    pending: "#r-pending-members"
  },

  initialize: function(options) {
    this.membersCollection = options.membersCollection;
    this.division = options.division;

    this.listenTo(BFApp.vent, "squad:form:add:player", function(user) {
      this.membersCollection.add(user);
    });

    this.listenTo(this.membersCollection, "add remove reset change", this.render);
  },

  onRender: function() {
    this.showMembers();

    // TODO: Check permissions. Only viewable by league admin.
    // this.showPendingMembers();
  },

  showMembers: function() {
    var members = this.membersCollection; //.byMember();
    this.showMemberTable("active", members, {
      title: "Members",
      showAddNew: true
    });
  },

  showPendingMembers: function() {
    var members = this.membersCollection.byPending();
    this.showMemberTable("pending", members, {
      title: "Pending Members",
      showAddNew: false
    });
  },

  showMemberTable: function(region, collection, options) {
    if (collection.length == 0) return this.showEmptyTable(region, options.title);

    var tableView = new BFApp.Views.MembersTableView({
      collection: collection,
      title: options.title,
      showAddNew: options.showAddNew
    });
    this[region].show(tableView);
  },

  showEmptyTable: function(region, title) {
    var emptyTableView = new BFApp.Views.EmptyMembersTableView({
      title: title
    });
    this[region].show(emptyTableView);
  }

});
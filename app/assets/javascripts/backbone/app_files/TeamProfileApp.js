var TeamProfileApp = _.extend({}, AppBase, {

  type: AppTypes.TeamProfile,

  Team: null,

  showView: function(view) {
    if (this.currentView) {
      this.currentView.close();
    }
    this.currentView = view;
    //console.log("BEFORE SHOW VIEW");
    $(".content").html(this.currentView.render().el);
    //console.log("AFTER SHOW VIEW");
  },

  init: function() {
    this.Teammates = new App.Collections.PlayersCollection();
  }

});
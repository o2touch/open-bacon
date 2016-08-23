BFApp.Views.MemberRowActionsView = Marionette.ItemView.extend({
  template: "backbone/templates/profiles/league/content/members/member_row_actions_view",

  initialize: function(options) {
    this.user = options.user;
  },

  ui: {
    edit: ".edit",
    approve: ".approve",
    reject: ".reject",
  },

  events: {
    "click @ui.edit": "clickedEdit",
    "click @ui.approve": "clickedApprove",
    "click @ui.reject": "clickedReject"
  },

  clickedEdit: function() {
    BFApp.vent.trigger("user:edit", this.user);
  }

});
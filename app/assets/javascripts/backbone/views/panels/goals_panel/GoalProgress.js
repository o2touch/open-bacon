BFApp.Views.GoalProgress = Marionette.ItemView.extend({

  template: "backbone/templates/panels/goals_panel/goal_progress",

  tagName: "header",

  serializeData: function() {
    return {
      tenantName: ActiveApp.Tenant.get("general_copy").app_name,
      percent: this.options.percentProgress
    };
  }

});
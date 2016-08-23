BFApp.Views.GoalsCompleteMsg = Marionette.ItemView.extend({

  template: "backbone/templates/panels/goals_panel/goals_complete_msg",

  serializeData: function() {
    return {
      tenant: ActiveApp.Tenant.get("general_copy").app_name
    };
  },

});